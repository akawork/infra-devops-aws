output "instance_id" {
  value = aws_instance.zabbix.id
}

output "private_ip" {
  value = aws_instance.zabbix.private_ip
}
