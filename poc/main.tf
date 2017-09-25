/* define the provider */

provider "aws" {
  region  = "eu-west-1"
  profile = "sandbox-keren"
}

// Global Variables

variable "default_tags" {
  type = "map"
  default = {
        Env = "POC"
        Team = "Keren"
        Function = "Bloggin platform using wordpress" 
  }
}

variable "environment" {
  type = "string"
  default = "poc"
}

// Modules definitions 

module "vpc" {
  source                      = "../modules/vpc"
  name                        = "wordpress-${var.environment}-vpc"
  cidr                        = "10.50.0.0/16"
  private_subnets             = "10.50.1.0/24,10.50.2.0/24,10.50.3.0/24"
  public_subnets              = "10.50.4.0/24,10.50.5.0/24,10.50.7.0/24"
  azs                         = "eu-west-1a,eu-west-1b,eu-west-1c"
  default_tags                = "${var.default_tags}"
}

module "rds" {
  source                      = "../modules/rds"
  environment                 = "${var.environment}"
  allocated_storage           = "5"
  engine_version              = "5.6.35"
  instance_type               = "db.t2.micro"
  vpc_id                      = "${module.vpc.vpc_id}"
  default_tags                = "${var.default_tags}"
  database_identifier         = "db-id-wordpress-${var.environment}"
  database_name               = "wordpress"
  database_password           = "IRSTR0NK"
  database_username           = "wordpress"

// RDS Security group

  security_group_name         = "sg_rds"
  source_cidr_block           = "0.0.0.0/0"
  database_port               = "3306"
  bastion_security_group      = "${module.bastion.security_group_id}"
  application_security_group  = "${module.elastic_beanstalk.security_group_id}"

// RDS Subnet group

  name                        = "wordpress_db_subnet_grp-${var.environment}"
  subnet_ids                  = "${module.vpc.private_subnets}"
}

module "elastic_beanstalk" {
  source                      = "../modules/elastic_beanstalk"
  solution_stack_name         = "64bit Amazon Linux 2017.03 v2.4.4 running PHP 7.0"
  vpcid                       = "${module.vpc.vpc_id}"
  beanstalk_bucket            = "keren-poc"
  app_version                 = "0.1.0"
  zip_name                    = "wordpress.zip"
  instanceType                = "t2.micro"
  EC2KeyName                  = "kerenasulin"
  autoscalingMinSize          = "2"
  autoscalingMaxSize          = "2"
  private_subnet_ids          = "${module.vpc.private_subnets}"
  public_subnet_ids           = "${module.vpc.public_subnets}"
  environment                 = "${var.environment}"
  default_tags                = "${var.default_tags}"

// Env variables
  
  rds_host                    = "${module.rds.address}"
  rds_user                    = "${module.rds.username}"
  rds_password                = "${module.rds.password}"
  rds_wordpress_database      = "${module.rds.db_name}"

// ElasticBeanstalk Security group

  bastion_security_group      = "${module.bastion.security_group_id}"
  security_group_name         = "wordpress_elasticbeanstalk_sg"
  source_cidr_block           = "0.0.0.0/0"
}

module "bastion" {
  source                      = "../modules/bastion"
  ami                         = "ami-f9dd458a"
  count                       = "1"
  environment                 = "${var.environment}"
  instance_type               = "t2.micro"
  key_name                    = "kerenasulin"
  subnet_id                   = "${module.vpc.public_subnets}"
  associate_public_ip_address = "true"
  source_dest_check           = "false"
  default_tags                = "${var.default_tags}"

// Bastion Security group

  security_group_name         = "wordpress_sg_bastion"
  vpc_id                      = "${module.vpc.vpc_id}"
  source_cidr_block           = "0.0.0.0/0"
  restricted_access           = "84.233.151.236/32,202.180.103.198/32"
}
