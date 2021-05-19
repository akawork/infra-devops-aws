output "instance_id" {
  value = aws_instance.bamboo.id
}

output "private_ip" {
  value = aws_instance.bamboo.private_ip
}

output "db_endpoint" {
  value = aws_db_instance.bamboo.endpoint
}

output "db_name" {
  value = aws_db_instance.bamboo.name
}

output "db_username" {
  value = aws_db_instance.bamboo.username
}

output "db_password" {
  value = "${var.db_password}"
}
