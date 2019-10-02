output "instance_id" {
  value = aws_instance.grafana.id
}

output "private_ip" {
  value = aws_instance.grafana.private_ip
}
