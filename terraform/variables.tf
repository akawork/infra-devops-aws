# Region variable
variable "region" {
  description = "Region for the the system"
  default     = "us-east-2"
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
variable "ami" {
  description = "Amazon Linux 2 AMI "
  default     = "ami-0ebbf2179e615c338"
}

# AMI template using for create NAT Instance
variable "ami_nat" {
  description = "Amazon Linux 2 AMI "
  default     = "ami-00d1f8201864cc10c"
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

