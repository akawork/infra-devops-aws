output "instance_id" {
  value = aws_instance.openldap.id
}

output "private_ip" {
  value = aws_instance.openldap.private_ip
}
