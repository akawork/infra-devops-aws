output "instance_id" {
  value = aws_instance.gitlab.id
}

output "private_ip" {
  value = aws_instance.gitlab.private_ip
}

output "db_endpoint" {
  value = aws_db_instance.gitlab.endpoint
}
