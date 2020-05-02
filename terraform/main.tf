/**
  Auto build DevOps system by infrastructure as code on AWS
**/

provider "aws" {
  version                 = "~> 2.13"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "mfa"
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

# Define domain name
data "aws_route53_zone" "default" {
  name         = var.domain_name
  private_zone = false
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

module "bastion" {
  source = "./modules/bastion"

  ami                       = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type             = "t2.micro"
  key_pair                  = aws_key_pair.bastion.id
  project_name              = var.project_name
  
  internal_private_key_path = var.internal_private_key_path
  bastion_private_key_path  = var.bastion_private_key_path
  remote_user               = "ec2-user"

  ip_address                = var.bastion_ip
  application1_subnet_cidr  = var.application1_subnet_cidr
  application2_subnet_cidr  = var.application2_subnet_cidr
  agent1_subnet_cidr        = var.agent1_subnet_cidr
  agent2_subnet_cidr        = var.agent2_subnet_cidr
  public_subnet_cidr        = var.public_subnet_cidr
  subnet_id                 = aws_subnet.public-subnet.id
  vpc_id                    = aws_vpc.devops.id

  squid_password            = var.squid_password
  squid_username            = var.squid_username
  squid_ip                  = var.squid_ip
  squid_port                = var.squid_port
  internal_ssh_key_name     = aws_key_pair.internal.key_name
}

module "confluence" {
  source = "./modules/confluence"

  ami                  = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type        = "t2.medium"
  key_pair             = aws_key_pair.internal.id
  project_name         = var.project_name

  ip_address           = var.confluence_ip
  bastion_private_ip   = var.bastion_ip
  nginx_public_ip      = aws_eip.nginx.public_ip
  nginx_private_ip     = module.nginx.private_ip

  route53_zone_id      = data.aws_route53_zone.default.zone_id
  route53_name         = data.aws_route53_zone.default.name    
  private1_subnet_cidr = var.private1_subnet_cidr
  private2_subnet_cidr = var.private2_subnet_cidr
  subnet_id            = aws_subnet.application1-subnet.id
  vpc_id               = aws_vpc.devops.id

  confluence_version   = var.confluence_version
  db_security_group    = aws_security_group.sgdb
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  db_storage           = var.confluence_storage
  db_engine            = var.confluence_engine
  db_engine_version    = var.confluence_engine_version
  db_instance_class    = var.confluence_instance_class
  db_name              = var.confluence_db_name
  db_username          = var.confluence_username
  db_password          = var.confluence_password

  enable               = var.confluence_enable
}

module "gitlab" {
  source = "./modules/gitlab"

  ami                  = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type        = "t2.medium"
  key_pair             = aws_key_pair.internal.id
  project_name         = var.project_name

  private_key          = var.internal_private_key_path
  bastion_key          = var.bastion_key_path
  bastion_private_key  = var.bastion_private_key_path

  ip_address           = var.gitlab_ip
  bastion_public_ip    = module.bastion.public_ip
  bastion_private_ip   = var.bastion_ip
  nginx_public_ip      = aws_eip.nginx.public_ip
  nginx_private_ip     = module.nginx.private_ip

  route53_zone_id      = data.aws_route53_zone.default.zone_id
  route53_name         = data.aws_route53_zone.default.name    
  private1_subnet_cidr = var.private1_subnet_cidr
  private2_subnet_cidr = var.private2_subnet_cidr
  subnet_id            = aws_subnet.application1-subnet.id
  vpc_id               = aws_vpc.devops.id

  db_security_group    = aws_security_group.sgdb
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  db_storage           = var.gitlab_storage
  db_engine            = var.gitlab_engine
  db_engine_version    = var.gitlab_engine_version
  db_instance_class    = var.gitlab_instance_class
  db_name              = var.gitlab_db_name
  db_username          = var.gitlab_username
  db_password          = var.gitlab_password

  enable               = var.gitlab_enable
}

module "grafana" {
  source = "./modules/grafana"

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type       = "t2.micro"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name

  bastion_host_key    = var.bastion_key_path
  bastion_private_key = var.bastion_private_key_path
  private_key         = var.internal_private_key_path
  remote_user         = "ec2-user"

  ip_address          = var.grafana_ip
  bastion_host        = module.bastion.public_ip
  bastion_private_ip  = var.bastion_ip
  nginx_public_ip     = aws_eip.nginx.public_ip
  nginx_private_ip    = module.nginx.private_ip
  prometheus_ip       = var.prometheus_ip

  route53_zone_id     = data.aws_route53_zone.default.zone_id
  route53_name        = data.aws_route53_zone.default.name    
  subnet_id           = aws_subnet.application1-subnet.id
  vpc_id              = aws_vpc.devops.id

  grafana_version     = var.grafana_version

  enable              = var.grafana_enable
}

module "jenkins" {
  source = "./modules/jenkins"

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type       = "t2.micro"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name

  bastion_host_key    = var.bastion_key_path
  bastion_private_key = var.bastion_private_key_path
  private_key         = var.internal_private_key_path
  remote_user         = "ec2-user"
  install_script      = "../scripts/install_jenkins.sh"

  ip_address          = var.jenkins_ip
  bastion_host        = module.bastion.public_ip
  bastion_private_ip  = var.bastion_ip
  nginx_public_ip     = aws_eip.nginx.public_ip
  nginx_private_ip    = module.nginx.private_ip

  route53_zone_id     = data.aws_route53_zone.default.zone_id
  route53_name        = data.aws_route53_zone.default.name    
  subnet_id           = aws_subnet.application1-subnet.id
  vpc_id              = aws_vpc.devops.id

  enable              = var.jenkins_enable
}

module "jira" {
  source = "./modules/jira"

  ami                  = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type        = "t2.medium"
  key_pair             = aws_key_pair.internal.id
  project_name         = var.project_name

  private_key          = var.internal_private_key_path
  bastion_key          = var.bastion_key_path
  bastion_private_key  = var.bastion_private_key_path

  ip_address           = var.jira_ip
  bastion_public_ip    = module.bastion.public_ip
  nginx_public_ip      = aws_eip.nginx.public_ip
  nginx_private_ip     = module.nginx.private_ip
  bastion_private_ip   = var.bastion_ip

  route53_zone_id      = data.aws_route53_zone.default.zone_id
  route53_name         = data.aws_route53_zone.default.name    
  private1_subnet_cidr = var.private1_subnet_cidr
  private2_subnet_cidr = var.private2_subnet_cidr
  subnet_id            = aws_subnet.application1-subnet.id
  vpc_id               = aws_vpc.devops.id

  jira_version         = var.jira_version
  db_security_group    = aws_security_group.sgdb
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  db_storage           = var.jira_storage
  db_engine            = var.jira_engine
  db_engine_version    = var.jira_engine_version
  db_instance_class    = var.jira_instance_class
  db_name              = var.jira_db_name
  db_username          = var.jira_username
  db_password          = var.jira_password

  enable               = var.jira_enable
}

module "nat_instance" {
  source = "./modules/nat_instance"

  ami                       = var.ami_nat_id == null ? data.aws_ami.amzn2_nat.image_id : var.ami_nat_id
  instance_type             = "t2.micro"
  key_pair                  = aws_key_pair.internal.id
  project_name              = var.project_name

  ip_address                = var.nat_ip
  bastion_private_ip        = var.bastion_ip

  application1_subnet_cidr  = var.application1_subnet_cidr
  application2_subnet_cidr  = var.application2_subnet_cidr
  agent1_subnet_cidr        = var.agent1_subnet_cidr
  agent2_subnet_cidr        = var.agent2_subnet_cidr
  public_subnet_cidr        = var.public_subnet_cidr
  subnet_id                 = aws_subnet.public-subnet.id
  vpc_id                    = aws_vpc.devops.id
}

module "nexus" {
  source = "./modules/nexus"

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type       = "t2.medium"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name

  ip_address          = var.nexus_ip
  nginx_public_ip     = aws_eip.nginx.public_ip
  nginx_private_ip    = module.nginx.private_ip
  bastion_private_ip  = var.bastion_ip

  route53_zone_id     = data.aws_route53_zone.default.zone_id
  route53_name        = data.aws_route53_zone.default.name    

  subnet_id           = aws_subnet.application1-subnet.id
  vpc_id              = aws_vpc.devops.id
  nexus_version       = var.nexus_version
  enable              = var.nexus_enable
}

module "nginx" {
  source = "./modules/nginx"

  ami                       = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type             = "t2.micro"
  key_pair                  = aws_key_pair.internal.id
  project_name              = var.project_name

  bastion_host_key          = var.bastion_key_path
  bastion_private_key       = var.bastion_private_key_path
  private_key               = var.internal_private_key_path
  remote_user               = "ec2-user"

  ip_address                = var.nginx_ip
  bastion_private_ip        = var.bastion_ip
  bastion_host              = module.bastion.public_ip

  nginx_config              = "../configs/nginx/nginx.conf"
  install_script            = "../scripts/install_nginx.sh"

  application1_subnet_cidr  = var.application1_subnet_cidr
  application2_subnet_cidr  = var.application2_subnet_cidr
  subnet_id                 = aws_subnet.public-subnet.id
  vpc_id                    = aws_vpc.devops.id
  route53_name              = data.aws_route53_zone.default.name   

  monitor_ip                = var.grafana_ip
  jenkins_ip                = var.jenkins_ip
  sonar_ip                  = var.sonar_ip
  nexus_ip                  = var.nexus_ip
  gitlab_ip                 = var.gitlab_ip
  jira_ip                   = var.jira_ip
  confluence_ip             = var.confluence_ip
}

module "openldap" {
  source = "./modules/openldap"

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type       = "t2.micro"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name

  ip_address          = var.openldap_ip
  bastion_private_ip  = var.bastion_ip
  nginx_public_ip     = aws_eip.nginx.public_ip
  nginx_private_ip    = module.nginx.private_ip

  route53_zone_id     = data.aws_route53_zone.default.zone_id
  route53_name        = data.aws_route53_zone.default.name    
 
  subnet_id           = aws_subnet.application1-subnet.id
  vpc_id              = aws_vpc.devops.id
  enable              = var.openldap_enable
}

module "prometheus" {
  source = "./modules/prometheus"

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type       = "t2.micro"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name

  bastion_host_key    = var.bastion_key_path
  bastion_private_key = var.bastion_private_key_path
  private_key         = var.internal_private_key_path
  remote_user         = "ec2-user"

  ip_address          = var.prometheus_ip
  bastion_host        = module.bastion.public_ip
  nginx_public_ip     = aws_eip.nginx.public_ip
  nginx_private_ip    = module.nginx.private_ip
  bastion_private_ip  = var.bastion_ip

  route53_zone_id     = data.aws_route53_zone.default.zone_id
  route53_name        = data.aws_route53_zone.default.name    

  subnet_id           = aws_subnet.application1-subnet.id
  vpc_id              = aws_vpc.devops.id
  prometheus_version  = var.prometheus_version
  enable              = var.prometheus_enable
}

module "sonarqube" {
  source = "./modules/sonarqube"

  ami                  = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type        = "t2.medium"
  key_pair             = aws_key_pair.internal.id
  project_name         = var.project_name

  ip_address           = var.sonar_ip
  bastion_private_ip   = var.bastion_ip
  nginx_public_ip      = aws_eip.nginx.public_ip
  nginx_private_ip     = module.nginx.private_ip

  route53_zone_id      = data.aws_route53_zone.default.zone_id
  route53_name         = data.aws_route53_zone.default.name    

  private1_subnet_cidr = var.private1_subnet_cidr
  private2_subnet_cidr = var.private2_subnet_cidr
  subnet_id            = aws_subnet.application1-subnet.id
  vpc_id               = aws_vpc.devops.id

  sonar_version        = var.sonar_version
  db_security_group    = aws_security_group.sgdb
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.id
  db_storage           = var.sonar_storage
  db_engine            = var.sonar_engine
  db_engine_version    = var.sonar_engine_version
  db_instance_class    = var.sonar_instance_class
  db_name              = var.sonar_db_name
  db_username          = var.sonar_username
  db_password          = var.sonar_password
  enable               = var.sonarqube_enable
}

module "squid" {
  source = "./modules/squid"

  ami                       = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type             = "t2.micro"
  key_pair                  = aws_key_pair.internal.id
  project_name              = var.project_name

  bastion_host_key          = var.bastion_key_path
  bastion_private_key       = var.bastion_private_key_path
  private_key               = var.internal_private_key_path
  remote_user               = "ec2-user"  

  ip_address                = var.squid_ip
  bastion_host              = module.bastion.public_ip
  bastion_private_ip        = var.bastion_ip
  nginx_public_ip           = aws_eip.nginx.public_ip
  nginx_private_ip          = module.nginx.private_ip

  application1_subnet_cidr  = var.application1_subnet_cidr
  application2_subnet_cidr  = var.application2_subnet_cidr
  agent1_subnet_cidr        = var.agent1_subnet_cidr
  agent2_subnet_cidr        = var.agent2_subnet_cidr
  public_subnet_cidr        = var.public_subnet_cidr

  subnet_id                 = aws_subnet.public-subnet.id
  vpc_id                    = aws_vpc.devops.id

  squid_password            = var.squid_password
  squid_username            = var.squid_username
  squid_port                = var.squid_port
}


module "zabbix" {
  source = "./modules/zabbix"

  ami                 = var.ami_id == null ? data.aws_ami.amzn2.image_id : var.ami_id
  instance_type       = "t2.micro"
  key_pair            = aws_key_pair.internal.id
  project_name        = var.project_name

  ip_address          = var.zabbix_ip
  bastion_private_ip  = var.bastion_ip
  nginx_public_ip     = aws_eip.nginx.public_ip
  nginx_private_ip    = module.nginx.private_ip

  route53_zone_id     = data.aws_route53_zone.default.zone_id
  route53_name        = data.aws_route53_zone.default.name    

  subnet_id           = aws_subnet.application1-subnet.id
  vpc_id              = aws_vpc.devops.id
  enable              = var.zabix_enable
}
