locals {
  naming_suffix = "bdm-${var.naming_suffix}"
}

module "instance" {
  source          = "github.com/UKHomeOffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.private_subnet.id}"
  user_data       = "LISTEN_HTTP=0.0.0.0:443 CHECK_RDS=${aws_db_instance.bdm_RDS_server.address}:5432"
  security_groups = ["${aws_security_group.bdm_web.id}"]
  private_ip      = "${var.dq_BDM_instance_ip}"

  tags = {
    Name = "instance-${local.naming_suffix}"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = "${var.apps_vpc_id}"
  cidr_block        = "${var.dq_BDM_subnet_cidr}"
  availability_zone = "${var.az}"

  tags {
    Name = "private-subnet-${local.naming_suffix}"
  }
}

resource "aws_subnet" "private_az2_subnet" {
  vpc_id            = "${var.apps_vpc_id}"
  cidr_block        = "${var.dq_BDM_subnet_az2_cidr}"
  availability_zone = "${var.az2}"

  tags {
    Name = "private-subnet2-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "bdm_private_subnet_rt_association" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_db_subnet_group" "bdm_db_group" {
  name = "main group"

  subnet_ids = [
    "${aws_subnet.private_subnet.id}",
    "${aws_subnet.private_az2_subnet.id}",
  ]

  tags {
    Name = "subnet-group-${local.naming_suffix}"
  }
}

resource "aws_security_group" "bdm_web" {
  vpc_id = "${var.apps_vpc_id}"

  ingress {
    from_port = "${var.https_from_port}"
    to_port   = "${var.https_to_port}"
    protocol  = "${var.https_protocol}"

    cidr_blocks = [
      "${var.dq_data_pipeline_cidr}",
      "${var.dq_opps_subnet_1_cidr}",
      "${var.peering_cidr_block}",
    ]
  }

  ingress {
    from_port = "${var.ssh_from_port}"
    to_port   = "${var.ssh_to_port}"
    protocol  = "${var.ssh_protocol}"

    cidr_blocks = [
      "${var.dq_opps_subnet_1_cidr}",
      "${var.peering_cidr_block}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg-web-${local.naming_suffix}"
  }
}

resource "aws_security_group" "bdm_RDS" {
  vpc_id = "${var.apps_vpc_id}"

  ingress {
    from_port = "${var.RDS_from_port}"
    to_port   = "${var.RDS_to_port}"
    protocol  = "${var.RDS_protocol}"

    cidr_blocks = [
      "${var.dq_opps_subnet_1_cidr}",
      "${var.dq_BDM_subnet_cidr}",
      "${var.peering_cidr_block}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg-RDS-${local.naming_suffix}"
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
    Name = "db-RDS-${local.naming_suffix}"
  }
}
