/**
  Auto build DevOps system by infrastructure as code on AWS
**/

provider "aws" {
  version                 = "~> 2.13"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
  region                  = var.region
}

# Get AMI ID for instances
data "aws_ami" "amzn2" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
}

# Get AMI ID for NAT instance
data "aws_ami" "amzn2_nat" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-hvm-*-x86_64-ebs"]
  }
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

# Define Subnet Group for DB
resource "aws_db_subnet_group" "db_subnet_group" {
  name        = var.project_name != "" ? lower("${var.project_name}_db_subnet_group") : "db_subnet_group"
  description = "Group of private subnets"
  subnet_ids  = [aws_subnet.private1-subnet.id, aws_subnet.private2-subnet.id]
}

# Define Bastion inside the public subnet
resource "aws_instance" "bastion-server" {
  ami           = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
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

#   ami               = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
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

  ami               = var.ami_nat_id == null ? data.aws_ami.amzn2_nat.image_id : var.ami_nat_id
  instance_type     = "t2.micro"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.nat_instance.id
}

module "nginx" {
  source = "./modules/nginx"

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
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

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
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

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
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

  ami               = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type     = "t2.medium"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.nexus.id
  install_script    = data.template_file.nexus_install.rendered
}

module "prometheus" {
  source = "./modules/prometheus"

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
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

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
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

  ami               = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type     = "t2.micro"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.zabbix.id
}

module "openldap" {
  source = "./modules/openldap"

  ami               = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type     = "t2.micro"
  key_pair          = aws_key_pair.internal.id
  project_name      = var.project_name
  network_interface = aws_network_interface.openldap.id
}

module "sonarqube" {
  source = "./modules/sonarqube"

  ami                  = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type        = "t2.medium"
  key_pair             = aws_key_pair.internal.id
  project_name         = var.project_name
  network_interface    = aws_network_interface.sonar.id
  install_script       = data.template_file.sonar_properties.rendered
  db_security_group    = aws_security_group.sgdb
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  db_storage           = var.sonar_storage
  db_engine            = var.sonar_engine
  db_engine_version    = var.sonar_engine_version
  db_instance_class    = var.sonar_instance_class
  db_name              = var.sonar_db_name
  db_username          = var.sonar_username
  db_password          = var.sonar_password
}

module "jira" {
  source = "./modules/jira"

  ami                  = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type        = "t2.medium"
  key_pair             = aws_key_pair.internal.id
  project_name         = var.project_name
  network_interface    = aws_network_interface.jira.id
  install_script       = data.template_file.jira_properties.rendered
  config_file          = template_dir.jira_config.destination_dir
  bastion_public_ip    = aws_instance.bastion-server.public_ip
  private_key          = var.internal_private_key_path
  bastion_key          = var.bastion_key_path
  bastion_private_key  = var.bastion_private_key_path
  db_security_group    = aws_security_group.sgdb
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  db_storage           = var.jira_storage
  db_engine            = var.jira_engine
  db_engine_version    = var.jira_engine_version
  db_instance_class    = var.jira_instance_class
  db_name              = var.jira_db_name
  db_username          = var.jira_username
  db_password          = var.jira_password
}

module "confluence" {
  source = "./modules/confluence"

  ami                  = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type        = "t2.medium"
  key_pair             = aws_key_pair.internal.id
  project_name         = var.project_name
  network_interface    = aws_network_interface.confluence.id
  install_script       = data.template_file.confluence_properties.rendered
  db_security_group    = aws_security_group.sgdb
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  db_storage           = var.confluence_storage
  db_engine            = var.confluence_engine
  db_engine_version    = var.confluence_engine_version
  db_instance_class    = var.confluence_instance_class
  db_name              = var.confluence_db_name
  db_username          = var.confluence_username
  db_password          = var.confluence_password
}

module "gitlab" {
  source = "./modules/gitlab"

  ami                  = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type        = "t2.medium"
  key_pair             = aws_key_pair.internal.id
  project_name         = var.project_name
  network_interface    = aws_network_interface.gitlab.id
  install_script       = data.template_file.gitlab_install.rendered
  config_file          = template_dir.gitlab_config.destination_dir
  bastion_public_ip    = aws_instance.bastion-server.public_ip
  private_key          = var.internal_private_key_path
  bastion_key          = var.bastion_key_path
  bastion_private_key  = var.bastion_private_key_path
  db_security_group    = aws_security_group.sgdb
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  db_storage           = var.gitlab_storage
  db_engine            = var.gitlab_engine
  db_engine_version    = var.gitlab_engine_version
  db_instance_class    = var.gitlab_instance_class
  db_name              = var.gitlab_db_name
  db_username          = var.gitlab_username
  db_password          = var.gitlab_password
}

module "keycloak" {
  source = "./modules/keycloak"
  ami                  = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type        = "t2.micro"
  key_pair             = aws_key_pair.internal.id
  project_name         = var.project_name
  network_interface    = aws_network_interface.keycloak.id
  install_script       = data.template_file.keycloak_install.rendered
  config_file          = null
  private_key          = var.internal_private_key_path
  bastion_key          = var.bastion_key_path
  bastion_private_key  = var.bastion_private_key_path  
  db_engine_version    = null
  db_subnet_group_name  = null
  bastion_public_ip     = null
  db_storage            = null
  db_username           = null
  db_password           = null
  bastion_key           = null
  db_instance_class     = null
  db_name               = null
  db_security_group     = null
}
