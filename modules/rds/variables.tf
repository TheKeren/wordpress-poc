// Global variables

variable "default_tags" {
    type = "map"
}

// RDS variables

variable "environment" {}
variable "allocated_storage" {}
variable "engine_version" {}
variable "instance_type" {}
variable "vpc_id" {}
variable "database_identifier" {}
variable "database_name" {}
variable "database_password" {}
variable "database_username" {}

// RDS Subnet group

variable "name" {}
variable "subnet_ids" {}

// RDS Security group variables

variable "database_port" {}
variable "security_group_name" {
  description = "The name for the security group"
}

variable "source_cidr_block" {
  description = "The source CIDR block to allow traffic from"
}

variable "bastion_security_group" {
  description = "Allow traffic from bastion host"
}

variable "application_security_group" {
  description = "Allow traffic from bastion host"
}

