output "instance_id" {
  value = aws_instance.jira.id
}

output "private_ip" {
  value = aws_instance.jira.private_ip
}

output "db_endpoint" {
  value = aws_db_instance.jira.endpoint
}
