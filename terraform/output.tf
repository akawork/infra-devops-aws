output "bastion_address" {
  value = aws_instance.bastion-server.public_ip
}

output "db_endpoint" {
  value = module.bamboo.db_endpoint
}

output "db_name" {
  value = module.bamboo.db_name
}

output "db_username" {
  value = module.bamboo.db_username
}

output "db_password" {
  value = module.bamboo.db_password
}
