output "instance_id" {
  value = aws_instance.nexus[0].id
}

output "private_ip" {
  value = aws_instance.nexus[0].private_ip
}
