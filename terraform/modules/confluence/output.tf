output "instance_id" {
  value = aws_instance.confluence[0].id
}

output "private_ip" {
  value = aws_instance.confluence[0].private_ip
}

output "db_endpoint" {
  value = aws_db_instance.confluence[0].endpoint
  description = "The database endpoint of the confluence."
}
