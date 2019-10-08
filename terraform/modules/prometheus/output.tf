output "instance_id" {
  value = aws_instance.prometheus.id
}

output "private_ip" {
  value = aws_instance.prometheus.private_ip
}
