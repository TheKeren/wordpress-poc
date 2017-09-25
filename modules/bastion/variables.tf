// Bastion server variables

variable "ami" {}
variable "count" {}
variable "environment" {}
variable "instance_type" {}
variable "key_name" {}
variable "subnet_id" {}
variable "associate_public_ip_address" {}
variable "source_dest_check" {}

variable "default_tags" {
  type = "map"
}

// Bastion security group variables

variable "security_group_name" {
  description = "The name for the security group"
}
variable "vpc_id" {
  description = "The VPC this security group will go in"
}
variable "source_cidr_block" {
  description = "The source CIDR block to allow traffic from"
}
variable "restricted_access" {
  description = "The source CIDR block to allow traffic from"
   default = ""
}

