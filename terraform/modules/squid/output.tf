output "instance_id" {
  value = aws_instance.squid.id
}

output "private_ip" {
  value = aws_instance.squid.private_ip
}
