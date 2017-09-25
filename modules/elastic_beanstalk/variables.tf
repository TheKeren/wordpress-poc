// Global variables

variable "default_tags" {
    type = "map"
}

variable "environment" {}

// ElasticBeanstalk variables

variable "solution_stack_name" {}
variable "vpcid" {}
variable "instanceType" {}
variable "EC2KeyName" {}
variable "autoscalingMinSize" {}
variable "autoscalingMaxSize" {}
variable "beanstalk_bucket" {}
variable "app_version" {}
variable "zip_name" {}

// Env variables

variable "rds_host" {}
variable "rds_user" {}
variable "rds_password" {}
variable "rds_wordpress_database" {}


// Subnet groups

variable "public_subnet_ids" {}
variable "private_subnet_ids" {}

// Security groups

variable "bastion_security_group" {}
variable "source_cidr_block" {}
variable "security_group_name" {}
