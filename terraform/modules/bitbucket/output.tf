output "instance_id" {
  value = aws_instance.bitbucket.id
}

output "private_ip" {
  value = aws_instance.bitbucket.private_ip
}
output "db_endpoint" {
  value = aws_db_instance.bitbucket.endpoint
}
