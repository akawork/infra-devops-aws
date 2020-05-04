variable "ami" {
  type        = string
  description = "AMI ID"
}

variable "project_name" {
  type        = string
  default     = ""
  description = "Project Name or System Name"
}

variable "instance_type" {
  type        = string
  description = "Instance type"
}

variable "key_pair" {
  type        = string
  description = "SSH key using for ssh remote connection"
}

variable "ip_address" {
  type        = string
  description = "IP address attach to Network Interface"
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

variable "domain_name" {
  type        = string
  description = "Defautl domain name"
}

variable "db_identifier" {
  default     = "jiradb"
  description = "Identifier for your DB"
}

variable "db_storage" {
  description = "Storage size in GB"
}

variable "db_engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "db_engine_version" {
  description = "Engine version"
}

variable "db_instance_class" {
  description = "Instance class"
}

variable "db_name" {
  description = "Database name"
}

variable "db_username" {
  description = "User name"
}

variable "db_password" {
  description = "Please enter password for SonarQube DB"
}

variable "db_security_group" {
  description = "Security group for Database"
}

variable "db_subnet_group_name" {
  description = "Subnet group for Database"
}

variable "bastion_public_ip" {
  type        = string
  description = "Bastion Public IP"
}

variable "private_key" {
  type        = string
  description = "Private Key Using for SSH to server"
}

variable "bastion_key" {
  type        = string
  description = "Private Key Using for SSH to server"
}

variable "bastion_private_key" {
  type        = string
  description = "Private Key Using for SSH to server"
}

variable "jira_version" {
  type        = string
  description = "Version of jira"
}

variable "enable" {
  type        = string
  description = "Enable service if the value is set to true"
}
