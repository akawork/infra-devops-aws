/**
  Auto build DevOps system by infrastructure as code on AWS
**/

provider "aws" {
  version                 = "~> 2.13"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
  region                  = var.region
}

# Define our VPC
resource "aws_vpc" "devops" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-VPC" : "VPC"
  }
}

module "nginx" {
  source = "./modules/nginx"

  ami                 = var.amis[var.region]
  instance_type       = "t2.micro"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name
  nginx_configd       = template_dir.nginx_conf.destination_dir
  nginx_config        = "../configs/nginx/nginx.conf"
  network_interface   = aws_network_interface.nginx.id
  install_script      = "../scripts/install_nginx.sh"
  bastion_host        = aws_instance.bastion-server.public_ip
  bastion_host_key    = var.bastion_key_path
  bastion_private_key = var.bastion_private_key_path
  private_key         = var.internal_private_key_path
  remote_user         = "ec2-user"
}

module "jenkins" {
  source = "./modules/jenkins"

  ami                 = var.amis[var.region]
  instance_type       = "t2.micro"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name
  network_interface   = aws_network_interface.jenkins.id
  install_script      = "../scripts/install_jenkins.sh"
  bastion_host        = aws_instance.bastion-server.public_ip
  bastion_host_key    = var.bastion_key_path
  bastion_private_key = var.bastion_private_key_path
  private_key         = var.internal_private_key_path
  remote_user         = "ec2-user"
}
