output "bdm_db_group_id" {
  value = "${aws_db_subnet_group.bdm_db_group.id}"
}

output "bdm_server_id" {
  value = "${aws_db_instance.bdm_RDS_server.id}"
}

output "bdm_db_server_ip_address" {
  value = "${aws_db_instance.bdm_RDS_server.address}"
}
