variable "instance_type" {
  default     = "t2.nano"
  description = "EC2 instance type"
}

variable "service" {
  default     = "dq-mdm"
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
