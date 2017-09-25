## RDS resources

resource "aws_db_instance" "wordpress-mysql" {
  allocated_storage       = "${var.allocated_storage}"
  engine                  = "mysql"
  engine_version          = "${var.engine_version}"
  identifier              = "${var.database_identifier}"
  instance_class          = "${var.instance_type}"
  name                    = "${var.database_name}"
  password                = "${var.database_password}"
  username                = "${var.database_username}"
  vpc_security_group_ids  = ["${aws_security_group.wordpress-rds_security_group.id}"]
  db_subnet_group_name    = "${aws_db_subnet_group.wordpress.id}"
  skip_final_snapshot     = true
  tags = "${merge(var.default_tags, map("Name", "wordpress-db"))}"
}

## RDS Subnet groups

resource "aws_db_subnet_group" "wordpress" {
  name       = "${var.name}"
  subnet_ids = ["${split(",", var.subnet_ids)}"]
  tags = "${merge(var.default_tags, map("Name", "wordpress DB subnet group"))}"
}

## RDS Security group

resource "aws_security_group" "wordpress-rds_security_group" {
  name        = "${var.security_group_name}"
  description = "Security Group for ${var.security_group_name}"
  vpc_id      = "${var.vpc_id}"

  // allows traffic from the SG itself for tcp
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  // allows traffic from the SG itself for udp
  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "udp"
    self      = true
  }

  // allow traffic from bation host
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${var.bastion_security_group}"]
  }

  // allow traffic from application node
  ingress {
    from_port       = 0
    to_port         = "${var.database_port}"
    protocol        = "tcp"
    security_groups = ["${var.application_security_group}"]
  }

  // allow node to call out
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.source_cidr_block}"]
  }

  tags = "${merge(var.default_tags, map("Name", "RDS security group"))}"
}


