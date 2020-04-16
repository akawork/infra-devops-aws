output "instance_id" {
  value = aws_instance.keycloak.id
}

output "private_ip" {
  value = aws_instance.keycloak.private_ip
}
