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

variable "network_interface" {
  type        = string
  description = "Network Interface define"
}

variable "install_script" {
  type        = string
  description = "Install jenkins script"
}

variable "config_file" {
  type        = string
  description = "Configuration File"
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
