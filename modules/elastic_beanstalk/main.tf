resource "aws_elastic_beanstalk_application" "wordpress" {
  name        = "wordpress-${var.environment}"
  description = "Logging plathform POC using wordpress"
}

resource "aws_elastic_beanstalk_application_version" "wordpress" {
  name        = "wordpress-${var.app_version}-${var.environment}"
  application = "${aws_elastic_beanstalk_application.wordpress.name}"
  description = "wordpress application version created by terraform"
  bucket      = "${var.beanstalk_bucket}"
  key         = "${var.app_version}/${var.zip_name}"
}

resource "aws_elastic_beanstalk_environment" "wordpress" {
  name                = "wordpress-${var.environment}"
  application         = "${aws_elastic_beanstalk_application.wordpress.name}"
  solution_stack_name = "${var.solution_stack_name}"
  tags                = "${merge(var.default_tags, map("Name", "wordpress"))}"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "${var.vpcid}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${element(split(",", var.private_subnet_ids), count.index)}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${element(split(",", var.public_subnet_ids), 0)}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "${var.instanceType}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.EC2KeyName}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${aws_security_group.wordpress-app_security_group.id}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = "${var.autoscalingMinSize}"
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = "${var.autoscalingMaxSize}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_ENDPOINT"
    value     = "${var.rds_host}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_USERNAME"
    value     = "${var.rds_user}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_PASSWORD"
    value     = "${var.rds_password}"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_DB_NAME"
    value     = "${var.rds_wordpress_database}"
  }

}

// EC2 App Security group

resource "aws_security_group" "wordpress-app_security_group" {
    name        = "${var.security_group_name}"
    description = "Security Group for ${var.security_group_name}"
    vpc_id      = "${var.vpcid}"
    tags        = "${merge(var.default_tags, map("Name", "wordpress-app-sg"))}"

    // allows traffic from the SG itself for tcp
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "tcp"
        self = true
    }

    // allows traffic from the SG itself for udp
    ingress {
        from_port = 0
        to_port = 65535
        protocol = "udp"
        self = true
    }

    // allow traffic for TCP 22
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = ["${var.bastion_security_group}"]
    }

    // allow traffic for TCP 80 
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
//        security_groups = ["${var.elb_security_group}"]
    }

    // allow node to call out
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.source_cidr_block}"]
    }

}

