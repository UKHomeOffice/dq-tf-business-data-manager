module "instance" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.private_subnet.id}"
  user_data       = "CHECK_self=127.0.0.1:8080 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_HTTP=0.0.0.0:443"
  security_groups = ["${aws_security_group.bdm_web.id}"]

  //  tags {
  //    Name             = "instance-bdm-{1}-${var.service}-${var.environment}"
  //    Service          = "${var.service}"
  //    Environment      = "${var.environment}"
  //    EnvironmentGroup = "${var.environment_group}"
  //  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = "${var.apps_vpc_id}"
  cidr_block = "${var.dq_BDM_subnet_cidr}"

  tags {
    Name             = "sn-dq-bdm-private-${var.service}-${var.environment}-{az}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

resource "aws_subnet" "private_az2_subnet" {
  vpc_id            = "${var.apps_vpc_id}"
  cidr_block        = "${var.dq_BDM_subnet_az2_cidr}"
  availability_zone = "${var.az2}"

  tags {
    Name             = "sn-dq-bdm-private-${var.service}-${var.environment}-az2"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

resource "aws_db_subnet_group" "bdm_db_group" {
  name = "main group"

  subnet_ids = [
    "${aws_subnet.private_subnet.id}",
    "${aws_subnet.private_az2_subnet.id}",
  ]

  tags {
    Name             = "dq-bdm-postgresql-${var.service}-${var.environment}-subnet-group"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

resource "aws_security_group" "bdm_web" {
  vpc_id = "${var.apps_vpc_id}"

  ingress {
    from_port   = "${var.https_from_port}"
    to_port     = "${var.https_to_port}"
    protocol    = "${var.https_protocol}"
    cidr_blocks = ["${var.dq_data_pipeline_cidr}", "${var.dq_opps_subnet_1_cidr}"]
  }

  ingress {
    from_port   = "${var.ssh_from_port}"
    to_port     = "${var.ssh_to_port}"
    protocol    = "${var.ssh_protocol}"
    cidr_blocks = ["${var.dq_opps_subnet_1_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name             = "sg-bdm-web-${var.service}-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

resource "aws_security_group" "bdm_RDS" {
  vpc_id = "${var.apps_vpc_id}"

  ingress {
    from_port   = "${var.RDS_from_port}"
    to_port     = "${var.RDS_to_port}"
    protocol    = "${var.RDS_protocol}"
    cidr_blocks = ["${var.dq_opps_subnet_1_cidr}", "${var.dq_BDM_subnet_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name             = "sg-bdm-web-${var.service}-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

resource "random_string" "password" {
  length  = 16
  special = false
}

resource "random_string" "username" {
  length  = 8
  special = false
}

resource "aws_db_instance" "bdm_RDS_server" {
  allocated_storage   = 10
  storage_type        = "gp2"
  engine              = "postgres"
  instance_class      = "db.t2.micro"
  username            = "${random_string.username.result}"
  password            = "${random_string.password.result}"
  skip_final_snapshot = true

  db_subnet_group_name   = "${aws_db_subnet_group.bdm_db_group.id}"
  publicly_accessible    = false
  vpc_security_group_ids = ["${aws_security_group.bdm_RDS.id}"]

  tags {
    Name             = "ec2-dq-bdm-postgresql-${var.service}-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}
