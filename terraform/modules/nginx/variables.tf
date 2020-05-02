variable "ami" {
  type        = string
  description = "AMI ID"
}

variable "instance_type" {
  type        = string
  description = "Type of instance"
}

variable "project_name" {
  type        = string
  default     = ""
  description = "Project Name or System Name"
}

variable "key_pair" {
  type        = string
  description = "SSH key using for ssh remote connection"
}

variable "nginx_config" {
  type        = string
  description = "nginx.conf file"
}

variable "install_script" {
  type        = string
  description = "Install Nginx script"
}

variable "bastion_host" {
  type        = string
  description = "Bastion Host IP for install Nginx in Local network"
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
  description = "Private key using for ssh to nginx server"
}

variable "remote_user" {
  type        = string
  description = "User using for remote to instance"
}

variable "ip_address" {
  type        = string
  description = "IP address attach to Network Interface"
}

variable "route53_name" {
  type        = string
  description = "Defautl domain name"
}

variable "bastion_private_ip" {
  type        = string
  description = "Private IP address of the Bastion"
}

variable "subnet_id" {
  type        = string
  description = "Subnet id attached by network interface"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "monitor_ip" {
  type        = string
  description = "IP address of Grafana"
}

variable "jenkins_ip" {
  type        = string
  description = "IP address of Jenkins"
}

variable "sonar_ip" {
  type        = string
  description = "IP address of Sonar"
}

variable "nexus_ip" {
  type        = string
  description = "IP address of Nexus"
}

variable "gitlab_ip" {
  type        = string
  description = "IP address of Gitlab"
}

variable "jira_ip" {
  type        = string
  description = "IP address of Jira"
}

variable "confluence_ip" {
  type        = string
  description = "IP address of Confluence"
}


variable "application1_subnet_cidr" {
  type        = string
  description = "Applicatioin 1 subnet CIDR"
}

variable "application2_subnet_cidr" {
  type        = string
  description = "Applicatioin 2 subnet CIDR"
}
