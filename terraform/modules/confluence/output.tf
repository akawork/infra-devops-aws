output "instance_id" {
  value = aws_instance.confluence.id
}

output "private_ip" {
  value = aws_instance.confluence.private_ip
}

output "db_endpoint" {
  value = aws_db_instance.confluence.endpoint
}
