output "instance_id" {
  value = aws_instance.nat_instance.id
}

output "private_ip" {
  value = aws_instance.nat_instance.private_ip
}
