output "instance_id" {
  value = aws_instance.openldap[0].id
}

output "private_ip" {
  value = aws_instance.openldap[0].private_ip
}
