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

variable "application1_subnet_cidr" {
  type        = string
  description = "Applicatioin 1 subnet CIDR"
}

variable "application2_subnet_cidr" {
  type        = string
  description = "Applicatioin 2 subnet CIDR"
}

variable "agent1_subnet_cidr" {
  type        = string
  description = "Agent 2 subnet CIDR"
}

variable "agent2_subnet_cidr" {
  type        = string
  description = "Agent 2 subnet CIDR"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR"
}

variable "subnet_id" {
  type        = string
  description = "Private IP address of the Bastion"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "squid_username" {
  type        = string
  description = "Username for squid admin"
}

variable "squid_password" {
  type        = string
  description = "password for squid admin"
}

variable "squid_port" {
  type        = string
  description = "Squid port listen"
}

variable "squid_ip" {
  type        = string
  description = "IP Squid server"
}

variable "internal_private_key_path" {
  type        = string
  description = "SSH Key to access internal instances"
}

variable "bastion_private_key_path" {
  type        = string
  description = "Bastion SSH Private Key path"
}

variable "remote_user" {
  type        = string
  description = "Username using for remote access"
}

variable "internal_ssh_key_name" {
  type        = string
  description = "SSH Keyname to access internal instances"
}
