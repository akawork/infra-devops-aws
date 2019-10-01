/**
  Auto build DevOps system by infrastructure as code on AWS
**/

provider "aws" {
  version                 = "~> 2.13"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
  region                  = var.region
}

# Define SSH key pair for our instances
resource "aws_key_pair" "bastion" {
  key_name   = "bastion-keypair"
  public_key = file(var.bastion_key_path)
}

resource "aws_key_pair" "internal" {
  key_name   = "internal-keypair"
  public_key = file(var.internal_key_path)
}

# Define our VPC
resource "aws_vpc" "devops" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-VPC" : "VPC"
  }
}

module "nat_instance" {
  source = "./modules/nat_instance"

  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.nat_instance.id
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

module "squid" {
  source = "./modules/squid"

  ami                 = var.amis[var.region]
  instance_type       = "t2.micro"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name
  network_interface   = aws_network_interface.squid.id
  install_script      = data.template_file.squid_install.rendered
  squid_config        = template_dir.squid_config.destination_dir
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

module "nexus" {
  source = "./modules/nexus"

  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.nexus.id
}

module "prometheus" {
  source = "./modules/prometheus"

  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.prometheus.id
}

module "grafana" {
  source = "./modules/grafana"

  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.grafana.id
}

module "zabbix" {
  source = "./modules/zabbix"

  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.zabbix.id
}

module "openldap" {
  source = "./modules/openldap"

  ami               = var.amis[var.region]
  instance_type     = "t2.micro"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.openldap.id
}
