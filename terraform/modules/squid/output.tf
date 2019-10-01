output "instance_id" {
  value = aws_instance.jenkins.id
}

output "private_ip" {
  value = aws_instance.jenkins.private_ip
}
