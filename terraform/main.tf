/**
  Auto build DevOps system by infrastructure as code on AWS
**/

provider "aws" {
  version = "~> 2.13"
  shared_credentials_file = "~/.aws/credentials"
  profile = "default"
  region     = "${var.region}"
}

# Define our VPC
resource "aws_vpc" "devops" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = {
    Name = "DevOps-VPC"
  }
}
