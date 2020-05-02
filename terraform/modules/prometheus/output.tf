output "instance_id" {
  value = aws_instance.prometheus[0].id
}

output "private_ip" {
  value = aws_instance.prometheus[0].private_ip
}
