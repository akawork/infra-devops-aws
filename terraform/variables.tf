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
  default     = "us-west-1"
}

# Define Availability Zone

variable "az_1" {
  default     = "us-west-1a"
  description = "First Availability Zone"
}

variable "az_2" {
  default     = "us-west-1b"
  description = "Second Availability Zone"
}

variable "domain_name" {
  default     = "demo1.akawork.io"
  description = "Your domain name"
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
variable "ami_id" {
  description = "AMI ID for instances"
  default     = null
}

# AMI template using for create NAT Instance
variable "ami_nat_id" {
  description = "AMI ID for NAT instance"
  default     = null
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
  default     = "DevOps365"
}

## GitLab

variable "gitlab_identifier" {
  default     = "gitlab"
  description = "Identifier for your DB"
}

variable "gitlab_storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "gitlab_engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "gitlab_engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.7.21"
    postgres = "9.6.8"
  }
}

variable "gitlab_instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "gitlab_db_name" {
  default     = "gitlabhq_production"
  description = "db name"
}

variable "gitlab_username" {
  default     = "gitlab"
  description = "User name"
}

variable "gitlab_password" {
  description = "Please enter password for GitLab DB"
  default     = "DevOps365"
}

## Jira

variable "jira_identifier" {
  default     = "jira"
  description = "Identifier for your DB"
}

variable "jira_storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "jira_engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "jira_engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.7.21"
    postgres = "9.6.8"
  }
}

variable "jira_instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "jira_db_name" {
  default     = "jira"
  description = "Database name"
}

variable "jira_username" {
  default     = "jira"
  description = "User name"
}

variable "jira_password" {
  description = "Please enter password for jira DB"
  default     = "DevOps365"
}

# Bamboo DB Variables
variable "bamboo_storage" {
  default     = "20"
  description = "Storage size in GB"
}

variable "bamboo_engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "bamboo_engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.7.21"
    postgres = "10.16"
  }
}

variable "bamboo_instance_class" {
  default     = "db.t3.micro"
  description = "Instance class"
}

variable "bamboo_db_name" {
  default     = "bamboo"
  description = "Database name"
}

variable "bamboo_username" {
  default     = "bamboouser"
  description = "User name"
}

variable "bamboo_password" {
  description = "Please enter password for jira DB"
  default     = "DevOps365"
}

## Confluence

variable "confluence_identifier" {
  default     = "confluence"
  description = "Identifier for your DB"
}

variable "confluence_storage" {
  default     = "10"
  description = "Storage size in GB"
}

variable "confluence_engine" {
  default     = "postgres"
  description = "Engine type, example values mysql, postgres"
}

variable "confluence_engine_version" {
  description = "Engine version"

  default = {
    mysql    = "5.7.21"
    postgres = "9.6.8"
  }
}

variable "confluence_instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "confluence_db_name" {
  default     = "confluence"
  description = "Database name"
}

variable "confluence_username" {
  default     = "confluence"
  description = "User name"
}

variable "confluence_password" {
  description = "Please enter password for jira DB"
  default     = "DevOps365"
}

######################################################
##                    Packages                      ##
######################################################

variable "nexus_version" {
  default     = "nexus-3.19.1-01"
  description = "Version of Nexus Repositpry OSS. https://github.com/sonatype/nexus-public/releases"
}

variable "sonar_version" {
  default     = "sonarqube-7.9.1"
  description = "Version of SonarQube. https://www.sonarqube.org/downloads/"
}

variable "jira_version" {
  default     = "atlassian-jira-software-8.3.1"
  description = "Version of Jira. https://www.atlassian.com/software/jira/download"
}

variable "confluence_version" {
  default     = "atlassian-confluence-6.15.7"
  description = "Version of Confluence. https://www.atlassian.com/software/confluence/download"
}

variable "prometheus_version" {
  default     = "2.11.1"
  description = "Version of Prometheus. https://prometheus.io/download/"
}

variable "grafana_version" {
  default     = "grafana-6.3.2-1"
  description = "Version of Grafana. https://grafana.com/grafana/download"
}

variable "bamboo_version" {
  default     = "atlassian-bamboo-7.2.3"
  description = "Version of Bamboo. https://www.atlassian.com/software/bamboo/download"
}

######################################################
##               Default Squid Config               ##
######################################################

# Username default for all server using Proxy in local netwowrk
variable "squid_username" {
  default     = "localproxy"
  description = "Username using for login Squid Proxy"
}

# Password default for all server using Proxy in local netwowrk
variable "squid_password" {
  default     = "Squ1dl0cal"
  description = "Password using for login Squid Proxy"
}

# Password default for all server using Proxy in local netwowrk
variable "squid_port" {
  default     = "8080"
  description = "Port using for access Squid Proxy"
}

######################################################
##                Default IP Address                ##
######################################################

variable "openldap_ip" {
  default     = "10.15.2.5"
  description = "IP of OpenLDAP Server"
}

variable "jira_ip" {
  default     = "10.15.2.10"
  description = "IP of Jira Server"
}

variable "bamboo_ip" {
  default     = "10.15.2.16"
  description = "IP of Bamboo Server"
}

variable "confluence_ip" {
  default     = "10.15.2.11"
  description = "IP of Jenkins Server"
}

variable "jenkins_ip" {
  default     = "10.15.2.12"
  description = "IP of Jenkins Server"
}

variable "sonar_ip" {
  default     = "10.15.2.13"
  description = "IP of sonar"
}

variable "nexus_ip" {
  default     = "10.15.2.14"
  description = "IP of Nexus Server"
}

variable "gitlab_ip" {
  default     = "10.15.2.15"
  description = "IP of GitLab Server"
}

variable "nginx_ip" {
  default     = "10.15.1.100"
  description = "IP of NginX Server"
}

variable "squid_ip" {
  default     = "10.15.1.101"
  description = "IP of Squid Proxy"
}

variable "nat_ip" {
  default     = "10.15.1.105"
  description = "IP of NAT Server"
}

variable "bastion_ip" {
  default     = "10.15.1.200"
  description = "IP of Bastion Proxy"
}

variable "zabbix_ip" {
  default     = "10.15.2.201"
  description = "IP of Zabbix Server"
}

variable "grafana_ip" {
  default     = "10.15.2.202"
  description = "IP of Grafana"
}

variable "prometheus_ip" {
  default     = "10.15.2.203"
  description = "IP of Prometheus"
}
