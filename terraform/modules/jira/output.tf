output "instance_id" {
  value = aws_instance.jira[0].id
}

output "private_ip" {
  value = aws_instance.jira[0].private_ip
}

output "db_endpoint" {
  value = aws_db_instance.jira[0].endpoint
}
