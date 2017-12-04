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
  vpc_security_group_ids = ["${aws_security_group.sgrp.id}"]
  user_data              = "CHECK_self=127.0.0.1:8080 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_HTTP=0.0.0.0:443"
  subnet_id              = "${aws_subnet.subnet.id}"

  tags {
    Name             = "instance-bdm-{1}-${var.service}-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}
