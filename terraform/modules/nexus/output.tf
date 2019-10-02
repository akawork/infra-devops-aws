output "instance_id" {
  value = aws_instance.nexus.id
}

output "private_ip" {
  value = aws_instance.nexus.private_ip
}
