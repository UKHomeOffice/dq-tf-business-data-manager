data "aws_ami" "linux_connectivity_tester" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "connectivity-tester-linux*",
    ]
  }

  owners = [
    "093401982388",
  ]
}

resource "aws_instance" "instance" {
  instance_type          = "${var.instance_type}"
  ami                    = "${data.aws_ami.linux_connectivity_tester.id}"
  vpc_security_group_ids = ["${aws_security_group.bdm_web.id}"]
  user_data              = "CHECK_self=127.0.0.1:8080 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_HTTP=0.0.0.0:443"
  subnet_id              = "${aws_subnet.private_subnet.id}"

  tags {
    Name             = "instance-bdm-{1}-${var.service}-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
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

resource "aws_db_subnet_group" "bdm_RDS_group" {
  name       = "main group"
  subnet_ids = ["${aws_subnet.private_subnet.id}"]

  tags {
    Name             = "dq-bdm-postgresql-${var.service}-${var.environment}-subnet-group"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

resource "aws_db_instance" "bdm_RDS_server" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = "RDS_.t1.micro"
  name                   = "${var.RDS_name}"
  username               = "${var.RDS_username}"
  password               = "${var.RDS_password}"
  db_subnet_group_name   = "${aws_db_subnet_group.bdm_RDS_group.id}"
  publicly_accessible    = false
  vpc_security_group_ids = ["${aws_security_group.bdm_RDS.id}"]

  tags {
    Name             = "ec2-dq-bdm-postgresql-${var.service}-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}
