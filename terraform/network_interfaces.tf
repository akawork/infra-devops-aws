# Define network interface for Bastion Server
resource "aws_network_interface" "bastion" {
  subnet_id         = aws_subnet.public-subnet.id
  private_ips       = ["10.15.1.200"]
  security_groups   = [aws_security_group.sgbastion.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-Bastion-Server"
  }
}

# Define network interface for Nginx Server
resource "aws_network_interface" "nginx" {
  subnet_id         = aws_subnet.public-subnet.id
  private_ips       = ["10.15.1.100"]
  security_groups   = [aws_security_group.sgnginx.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-Nginx-Server"
  }
}

# Define network interface for NAT Server
resource "aws_network_interface" "nat_instance" {
  subnet_id         = aws_subnet.public-subnet.id
  private_ips       = ["10.15.1.105"]
  security_groups   = [aws_security_group.sgnat.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-NAT-Server"
  }
}

# Define network interface for Squid Server
resource "aws_network_interface" "squid" {
  subnet_id         = aws_subnet.public-subnet.id
  private_ips       = ["10.15.1.101"]
  security_groups   = [aws_security_group.sgsquid.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-Squid-Server"
  }
}

# Define network interface for OpenLDAP Server
resource "aws_network_interface" "openldap" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.5"]
  security_groups   = [aws_security_group.sgopenldap.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-OpenLDAP-Server"
  }
}

# Define network interface for Jira Server
resource "aws_network_interface" "jira" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.10"]
  security_groups   = [aws_security_group.sgjira.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-Jira-Server"
  }
}

# Define network interface for Confluence Server
resource "aws_network_interface" "confluence" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.11"]
  security_groups   = [aws_security_group.sgconfluence.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-Confluence-Server"
  }
}

# Define network interface for Jenkins Server
resource "aws_network_interface" "jenkins" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.12"]
  security_groups   = [aws_security_group.sgjenkins.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-Jenkins-Server"
  }
}

# Define network interface for Sonar Server
resource "aws_network_interface" "sonar" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.13"]
  security_groups   = [aws_security_group.sgsonar.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-Sonar-Server"
  }
}

# Define network interface for Nexus Server
resource "aws_network_interface" "nexus" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.14"]
  security_groups   = [aws_security_group.sgnexus.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-Nexus-Server"
  }
}

# Define network interface for GitLab Server
resource "aws_network_interface" "gitlab" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.15"]
  security_groups   = [aws_security_group.sggitlab.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-GitLab-Server"
  }
}

# Define network interface for Zabbix Server
resource "aws_network_interface" "zabbix" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.201"]
  security_groups   = [aws_security_group.sgzabbix.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-Zabbix-Server"
  }
}

# Define network interface for Grafana Server
resource "aws_network_interface" "grafana" {
  subnet_id         = aws_subnet.application1-subnet.id
  private_ips       = ["10.15.2.202"]
  security_groups   = [aws_security_group.sggrafana.id]
  source_dest_check = false

  tags = {
    Name = "DevOps-Grafana-Server"
  }
}
