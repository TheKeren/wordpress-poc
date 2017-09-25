// Bstion Server

resource "aws_instance" "bastion" {
  ami                         = "${var.ami}"
  count                       = "${var.count}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.wordpress_bastion_security_group.id}"]
  subnet_id                   = "${element(split(",", var.subnet_id), count.index)}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  source_dest_check           = "${var.source_dest_check}"
  tags                        = "${merge(var.default_tags, map("Name", "wordpress-bastion"))}"
}

// Bastion Security group

resource "aws_security_group" "wordpress_bastion_security_group" {
    name = "${var.security_group_name}"
    tags = "${merge(var.default_tags, map("Name", "Bstion server security group"))}"
    description = "Security Group for ${var.security_group_name}"
    vpc_id = "${var.vpc_id}"

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

    // allow traffic for TCP 22 from authourized ip addresses array
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${split(",", var.restricted_access)}"]
    }

    // allow node to call out
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.source_cidr_block}"]
    }
}
