output "instance_id" {
  value = aws_instance.rocketchat.id
}

output "private_ip" {
  value = aws_instance.rocketchat.private_ip
}
