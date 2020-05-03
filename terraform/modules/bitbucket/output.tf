output "instance_id" {
  value = aws_instance.bitbucket[0].id
}

output "private_ip" {
  value = aws_instance.bitbucket[0].private_ip
}
output "db_endpoint" {
  value = aws_db_instance.bitbucket[0].endpoint
}
