variable "ami" {
  description = "AMI ID"
}

variable "project_name" {
  default     = ""
  description = "Project Name or System Name"
}

variable "instance_type" {
  description = "Instance type"
}

variable "key_pair" {
  description = "SSH key using for ssh remote connection"
}

variable "bastion_host" {
  description = "Bastion Host IP for install jenkins in Local network"
}

variable "bastion_host_key" {
  description = "Bastion host key"
}

variable "bastion_private_key" {
  description = "Bastion private key"
}

variable "private_key" {
  description = "Private key using for ssh to jenkins server"
}

variable "remote_user" {
  description = "User using for remote to instance"
}

variable "ip_address" {
  type        = string
  description = "IP address attach to Network Interface"
}

variable "domain_name" {
  type        = string
  description = "Defautl domain name"
}

variable "route53_zone_id" {
  type        = string
  description = "Zone ID of domain"
}

variable "route53_name" {
  type        = string
  description = "Defautl domain name"
}

variable "nginx_public_ip" {
  type        = string
  description = "Elastic IP address of the Nginx"
}

variable "nginx_private_ip" {
  type        = string
  description = "Private IP address of the Nginx"
}

variable "private1_subnet_cidr" {
  type        = string
  description = "Private 1 subnet CIDR"
}

variable "private2_subnet_cidr" {
  type        = string
  description = "Private 2 subnet CIDR"
}

variable "bastion_private_ip" {
  type        = string
  description = "Private IP address of the Bastion"
}

variable "subnet_id" {
  type        = string
  description = "Private IP address of the Bastion"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

# variable "java_installer" {
#   description = "Url to upload Oracle Java to server"
# }

# DATABASE VARIABLES
# variable "db_depends_on" {
#   description = "Database "
# }

variable "db_identifier" {
  description = "Database "
}

variable "db_allocated_storage" {
  description = "Database "
}

variable "db_engine" {
  description = "Database "
}

variable "db_engine_version" {
  description = "Database "
}

variable "db_instance_class" {
  description = "Database "
}

variable "db_name" {
  description = "Database "
}

variable "db_username" {
  description = "Database "
}

variable "db_password" {
  description = "Database "
}

variable "db_security_group" {
  description = "Database "
}

variable "db_subnet_group_name" {
  description = "Database "
}

variable "bitbucket_version" {
  type        = string
  description = "Version of bitbucket"
}

variable "enable" {
  type        = string
  description = "Enable service if the value is set to true"
}
