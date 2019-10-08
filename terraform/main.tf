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

# Define Bastion inside the public subnet
resource "aws_instance" "bastion-server" {
  ami           = var.amis[var.region]
  instance_type = "t2.nano"
  key_name      = aws_key_pair.bastion.id
  user_data     = data.template_file.bastion_config.rendered

  network_interface {
    network_interface_id = aws_network_interface.bastion.id
    device_index         = 0
  }

  # Copies the internal-key to /home/ec2-user
  provisioner "file" {
    source      = "../keypair/internal-key"
    destination = "/home/ec2-user/internal-key"
    connection {
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file(var.bastion_private_key_path)
    }
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bastion-Server" : "Bastion-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bastion-Server" : "Bastion-Server"
  }
}

# module "bastion" {
#   source = "./modules/bastion"

#   ami               = var.amis[var.region]
#   instance_type     = "t2.micro"
#   key_pair          = aws_key_pair.bastion.id
#   project_name      = var.project_name
#   network_interface = aws_network_interface.bastion.id
#   internal_key      = "../keypair/internal-key"
#   private_key       = var.internal_private_key_path
#   remote_user       = "ec2-user"
#   config_script     = data.template_file.bastion_config.rendered
# }

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
  instance_type     = "t2.small"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.nexus.id
  install_script    = data.template_file.nexus_install.rendered
}

module "prometheus" {
  source = "./modules/prometheus"

  ami                 = var.amis[var.region]
  instance_type       = "t2.micro"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name
  network_interface   = aws_network_interface.prometheus.id
  prometheus_config   = template_dir.prometheus_config.destination_dir
  install_script      = data.template_file.prometheus_install.rendered
  bastion_host        = aws_instance.bastion-server.public_ip
  bastion_host_key    = var.bastion_key_path
  bastion_private_key = var.bastion_private_key_path
  private_key         = var.internal_private_key_path
  remote_user         = "ec2-user"
}

module "grafana" {
  source = "./modules/grafana"

  ami                 = var.amis[var.region]
  instance_type       = "t2.micro"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name
  network_interface   = aws_network_interface.grafana.id
  install_script      = data.template_file.grafana_install.rendered
  grafana_config      = template_dir.grafana_config.destination_dir
  bastion_host        = aws_instance.bastion-server.public_ip
  bastion_host_key    = var.bastion_key_path
  bastion_private_key = var.bastion_private_key_path
  private_key         = var.internal_private_key_path
  remote_user         = "ec2-user"
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
