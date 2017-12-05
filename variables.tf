variable "instance_type" {
  default     = "t2.nano"
  description = "EC2 instance type"
}

variable "service" {
  default     = "dq-bdm"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.4 document"
}

variable "environment" {
  default     = "preprod"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.4 document"
}

variable "environment_group" {
  default     = "dq-apps"
  description = "As per naming standards in AWS-DQ-Network-Routing 0.4 document"
}

variable "apps_vpc_id" {
  default     = false
  description = "Value obtained from Apps module"
}

variable "dq_BDM_subnet_cidr" {
  default     = "10.1.10.0/24"
  description = "DQ BDM subnet CIDR as per IP Addresses and CIDR blocks document"
}

variable "https_from_port" {
  default     = 443
  description = "From port for HTTPS traffic"
}

variable "https_to_port" {
  default     = 443
  description = "To port for HTTPS traffic"
}

variable "https_protocol" {
  default     = "tcp"
  description = "Protocol for HTTPS traffic"
}

variable "RDS_from_port" {
  default     = 5432
  description = "From port for RDS server traffic"
}

variable "RDS_to_port" {
  default     = 5432
  description = "To port for RDS server traffic"
}

variable "RDS_protocol" {
  default     = "tcp"
  description = "Protocol for RDS server traffic"
}

variable "dq_apps_cidr" {
  default     = "10.1.0.0/16"
  description = "DQ Apps CIDR as per IP Addresses and CIDR blocks document"
}

variable "RDS_name" {}

variable "RDS_username" {}

variable "RDS_password" {}

variable dq_data_pipeline_cidr {
  default     = "10.1.8.0/24"
  description = "DQ Data Pipeline CIDR as per IP Addresses and CIDR blocks document"
}

variable dq_opps_subnet_1_cidr {
  default     = "10.2.0.0/24"
  description = "DQ Ops Subnet 1 CIDR as per IP Addresses and CIDR blocks document"
}

variable ssh_from_port {
  default     = 22
  description = "From port for SSH traffic"
}

variable ssh_to_port {
  default     = 22
  description = "To port for SSH traffic"
}

variable ssh_protocol {
  default     = "tcp"
  description = "Protocol for SSH traffic"
}

variable "az2" {
  default     = "eu-west-2b"
  description = "Availability zone no2 for RDS implementation"
}

variable "dq_BDM_subnet_az2_cidr" {
  default     = "10.1.11.0/24"
  description = "DQ BDM Subnet in availability zone number 2"
}
