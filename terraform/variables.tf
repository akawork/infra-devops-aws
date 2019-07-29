######################################################
##                      Project                     ##
######################################################
variable "project_name" {
  description = "Project name here"
  default     = "DevOps"
}

######################################################
##                     Region                       ##
######################################################
# Region variable
variable "region" {
  description = "Region for the the system"
  default     = "us-east-2"
}

# Define Availability Zone

variable "az_1" {
  default     = "us-east-2a"
  description = "First Availability Zone"
}

variable "az_2" {
  default     = "us-east-2b"
  description = "Second Availability Zone"
}

variable "domain_name" {
  default     = "demo.akawork.io."
  description = "Your domain name"
}

variable "project_namespace" {
  default     = "DevOps"
  description = "Your Project Namespace"
}

######################################################
##                      VPC                         ##
######################################################

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "10.15.0.0/16"
}

# Define subnets

# Public subnets
variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  default     = "10.15.1.0/24"
}

# Application subnets
variable "application1_subnet_cidr" {
  description = "CIDR for the application1 subnet"
  default     = "10.15.2.0/24"
}

variable "application2_subnet_cidr" {
  description = "CIDR for the application2 subnet"
  default     = "10.15.3.0/24"
}

# Private subnets
variable "private1_subnet_cidr" {
  description = "CIDR for the private1 subnet"
  default     = "10.15.10.0/24"
}

variable "private2_subnet_cidr" {
  description = "CIDR for the private2 subnet"
  default     = "10.15.11.0/24"
}

# Agent subnets
variable "agent1_subnet_cidr" {
  description = "CIDR for the agent1 subnet"
  default     = "10.15.16.0/24"
}

variable "agent2_subnet_cidr" {
  description = "CIDR for the agent2 subnet"
  default     = "10.15.17.0/24"
}

######################################################
##               Define AMI Templates               ##
######################################################

# Common AMI template using for almost instances
variable "amis" {
  type        = "map"
  description = "Amazon Linux 2 AMI "
  default = {
    "us-east-1"      = "ami-0b898040803850657"
    "us-east-2"      = "ami-0ebbf2179e615c338"
    "us-west-1"      = "ami-056ee704806822732"
    "us-west-2"      = "ami-082b5a644766e0e6f"
    "ap-southeast-1" = "ami-01f7527546b557442"
  }
}

# AMI template using for create NAT Instance
variable "amis_nat" {
  type        = "map"
  description = "Amazon Linux AMI "
  default = {
    "us-east-1"      = "ami-00a9d4a05375b2763"
    "us-east-2"      = "ami-00d1f8201864cc10c"
    "us-west-1"      = "ami-097ad469381034fa2"
    "us-west-2"      = "ami-0b840e8a1ce4cdf15"
    "ap-southeast-1" = "ami-01514bb1776d5c018"
  }
}

######################################################
##                    KEY PAIR                      ##
######################################################

variable "bastion_key_path" {
  description = "SSH Public Key path"
  default     = "../keypair/bastion-key.pub"
}

variable "internal_key_path" {
  description = "SSH Public Key path"
  default     = "../keypair/internal-key.pub"
}

variable "bastion_private_key_path" {
  description = "SSH Private Key path"
  default     = "../keypair/bastion-key"
}

variable "internal_private_key_path" {
  description = "SSH Private Key path"
  default     = "../keypair/internal-key"
}

######################################################
##                      RDS                         ##
######################################################

## SonarQube

variable "sonar_identifier" {
  default     = "sonarqube"
  description = "Identifier for your DB"
}

variable "sonar_storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "sonar_engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "sonar_engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.7.21"
    postgres = "9.6.8"
  }
}

variable "sonar_instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "sonar_db_name" {
  default     = "sonarqube"
  description = "Database name"
}

variable "sonar_username" {
  default     = "sonarqube"
  description = "User name"
}

variable "sonar_password" {
  description = "Please enter password for SonarQube DB"
  default = "DevOps365"
}
