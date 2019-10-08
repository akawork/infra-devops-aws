variable "ami" {
  description = "AMI ID"
}

variable "project_name" {
  default     = ""
  description = "Project Name or System Name"
}

variable "bitbucket_config" {
  description = "Bitbucket Configuration files"
}

variable "instance_type" {
  description = "Instance type"
}

variable "key_pair" {
  description = "SSH key using for ssh remote connection"
}

variable "network_interface" {
  description = "Network Interface define"
}

variable "install_script" {
  description = "Install jenkins script"
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
