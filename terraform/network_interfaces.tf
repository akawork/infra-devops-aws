# Define network interface for Bastion Server
resource "aws_network_interface" "bastion" {
  subnet_id         = aws_subnet.public-subnet.id
  private_ips       = [var.bastion_ip]
  security_groups   = [aws_security_group.sgbastion.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bastion-Server" : "Bastion-Server"
  }
}

# Define network interface for Nginx Server
resource "aws_network_interface" "nginx" {
  subnet_id         = aws_subnet.public-subnet.id
  private_ips       = ["10.15.1.100"]
  security_groups   = [aws_security_group.sgnginx.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nginx-Server" : "Nginx-Server"
  }
}

# Define network interface for NAT Server
resource "aws_network_interface" "nat_instance" {
  subnet_id         = aws_subnet.public-subnet.id
  private_ips       = ["10.15.1.105"]
  security_groups   = [aws_security_group.sgnat.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NAT-Server" : "NAT-Server"
  }
}

# Define network interface for Squid Server
resource "aws_network_interface" "squid" {
  subnet_id         = aws_subnet.public-subnet.id
  private_ips       = [var.squid_ip]
  security_groups   = [aws_security_group.sgsquid.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Squid-Server" : "Squid-Server"
  }
}

# Define network interface for OpenLDAP Server
resource "aws_network_interface" "openldap" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.5"]
  security_groups   = [aws_security_group.sgopenldap.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server" : "OpenLDAP-Server"
  }
}

# Define network interface for Jira Server
resource "aws_network_interface" "jira" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.10"]
  security_groups   = [aws_security_group.sgjira.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jira-Server" : "Jira-Server"
  }
}

# Define network interface for Confluence Server
resource "aws_network_interface" "confluence" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.11"]
  security_groups   = [aws_security_group.sgconfluence.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Confluence-Server" : "Confluence-Server"
  }
}

# Define network interface for Jenkins Server
resource "aws_network_interface" "jenkins" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.12"]
  security_groups   = [aws_security_group.sgjenkins.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jenkins-Server" : "Jenkins-Server"
  }
}

# Define network interface for Sonar Server
resource "aws_network_interface" "sonar" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = [var.sonar_ip]
  security_groups   = [aws_security_group.sgsonar.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Sonar-Server" : "Sonar-Server"
  }
}

# Define network interface for Nexus Server
resource "aws_network_interface" "nexus" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.14"]
  security_groups   = [aws_security_group.sgnexus.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server" : "Nexus-Server"
  }
}

# Define network interface for GitLab Server
resource "aws_network_interface" "gitlab" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.15"]
  security_groups   = [aws_security_group.sggitlab.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-GitLab-Server" : "GitLab-Server"
  }
}

# Define network interface for Zabbix Server
resource "aws_network_interface" "zabbix" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.201"]
  security_groups   = [aws_security_group.sgzabbix.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Zabbix-Server" : "Zabbix-Server"
  }
}

# Define network interface for Grafana Server
resource "aws_network_interface" "grafana" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = [var.grafana_ip]
  security_groups   = [aws_security_group.sggrafana.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Grafana-Server" : "Grafana-Server"
  }
}

# Define network interface for Prometheus Server
resource "aws_network_interface" "prometheus" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = [var.prometheus_ip]
  security_groups   = [aws_security_group.sgprometheus.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Prometheus-Server" : "Prometheus-Server"
  }
}
