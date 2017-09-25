// RDS outputs

output "db_name" {
  value = "${aws_db_instance.wordpress-mysql.name}"
}

output "username" {
  value = "${aws_db_instance.wordpress-mysql.username}"
}

output "password" {
  value = "${aws_db_instance.wordpress-mysql.password}"
}

output "address" {
  value = "${aws_db_instance.wordpress-mysql.address}"
}
