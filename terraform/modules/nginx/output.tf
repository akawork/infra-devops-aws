output "instance_id" {
  value = aws_instance.nginx.id
}

output "private_ip" {
  value = aws_instance.nginx.private_ip
}
