output "bastion_address" {
  value = aws_instance.bastion-server.public_ip
}
