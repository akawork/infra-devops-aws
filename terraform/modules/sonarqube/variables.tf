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

variable "sonar_identifier" {
  default     = "sonarqube"
  description = "Identifier for your DB"
}

variable "sonar_storage" {
  description = "Storage size in GB"
}

variable "sonar_engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "sonar_engine_version" {
  description = "Engine version"
}

variable "sonar_instance_class" {
  description = "Instance class"
}

variable "sonar_db_name" {
  description = "Database name"
}

variable "sonar_username" {
  description = "User name"
}

variable "sonar_password" {
  description = "Please enter password for SonarQube DB"
}

variable "sgdb" {
  description = "Security group for Database"
}

variable "db_subnet_group_name" {
  description = "Subnet group for Database"
}
