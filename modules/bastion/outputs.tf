output "bastion_public_ip" {
  value = "${join(",", aws_instance.bastion.*.public_ip)}"
}

output "security_group_id" {
  value = "${aws_security_group.wordpress_bastion_security_group.id}"
}

