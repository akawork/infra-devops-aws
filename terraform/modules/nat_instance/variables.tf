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
