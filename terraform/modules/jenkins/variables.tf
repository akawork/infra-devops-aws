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

variable "install_script" {
  type        = string
  description = "Install jenkins script"
}

variable "bastion_host" {
  type        = string
  description = "Bastion Host IP for install jenkins in Local network"
}

variable "bastion_host_key" {
  type        = string
  description = "Bastion host key"
}

variable "bastion_private_key" {
  type        = string
  description = "Bastion private key"
}

variable "private_key" {
  type        = string
  description = "Private key using for ssh to jenkins server"
}

variable "remote_user" {
  type        = string
  description = "User using for remote to instance"
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

variable "jenkins_version" {
  type        = string
  description = "Version of jenkins"
}

variable "enable" {
  type        = string
  description = "Enable service if the value is set to true"
}
