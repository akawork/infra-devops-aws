variable "ami" {
  type        = string
  description = "AMI ID"
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

variable "nginx_configd" {
  type        = string
  description = "Collect all configuration files in config.d"
}

variable "network_interface" {
  type        = string
  description = "Network Interface define"
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
