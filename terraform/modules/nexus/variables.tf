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

variable "nexus_version" {
  type        = string
  description = "Version of Nexus Repositpry OSS. https://github.com/sonatype/nexus-public/releases"
}

variable "enable" {
  type        = string
  description = "Enable service if the value is set to true"
}
