# Define SSH key pair for our instances
resource "aws_key_pair" "bastion" {
  key_name   = "bastion-keypair"
  public_key = file(var.bastion_key_path)
}

resource "aws_key_pair" "internal" {
  key_name   = "internal-keypair"
  public_key = file(var.internal_key_path)
}

# Define webserver inside the public subnet
resource "aws_instance" "bastion-server" {
  ami           = var.amis[var.region]
  instance_type = "t2.nano"
  key_name      = aws_key_pair.bastion.id

  network_interface {
    network_interface_id = aws_network_interface.bastion.id
    device_index         = 0
  }

  # provisioner "local-exec" {
  #   command = "sudo su"
  # }

  # provisioner "local-exec" {
  #   command = "sudo sed -i 's/#Port 22/Port 443/g' /etc/ssh/sshd_config"
  # }

  tags = {
    Name = "DevOps-Bastion-Server"
  }

  volume_tags = {
    Name = "DevOps-Bastion-Server"
  }
}

# Define NAT Instance Server inside the public subnet
resource "aws_instance" "nat_instance" {
  ami           = var.amis_nat[var.region]
  instance_type = "t2.nano"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.nat_instance.id
    device_index         = 0
  }

  tags = {
    Name = "DevOps-NAT-Server"
  }

  volume_tags = {
    Name = "DevOps-NAT-Server"
  }
}

# Define NAT Instance Server inside the public subnet
resource "aws_instance" "squid" {
  ami           = var.amis[var.region]
  instance_type = "t2.nano"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.squid.id
    device_index         = 0
  }

  tags = {
    Name = "DevOps-Squid-Server"
  }

  volume_tags = {
    Name = "DevOps-Squid-Server"
  }
}

# Define NginX Server inside the public subnet
resource "aws_instance" "nginx" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  #  user_data = "${file("./scripts/install_nginx.sh")}"
  network_interface {
    network_interface_id = aws_network_interface.nginx.id
    device_index         = 0
  }

  tags = {
    Name = "DevOps-NginX-Server"
  }

  volume_tags = {
    Name = "DevOps-NginX-Server"
  }
}

# Define Nexus Server inside the private subnet
resource "aws_instance" "nexus" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.nexus.id
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_nexus.sh")}"

  tags = {
    Name = "DevOps-Nexus-Server"
  }

  volume_tags = {
    Name = "DevOps-Nexus-Server"
  }
}

# Define Sonarqube Server inside the private subnet
resource "aws_instance" "sonarqube" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.sonar.id
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_sonar.sh")}"

  tags = {
    Name = "DevOps-Sonarqube-Server"
  }

  volume_tags = {
    Name = "DevOps-Sonarqube-Server"
  }
}

# Define Jenkins Server inside the private subnet
resource "aws_instance" "jenkins" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.jenkins.id
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_jenkins.sh")}"

  tags = {
    Name = "DevOps-Jenkins-Server"
  }

  volume_tags = {
    Name = "DevOps-Jenkins-Server"
  }
}

# Define Jira Server inside the private subnet
resource "aws_instance" "jira" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.jira.id
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_jira.sh")}"

  tags = {
    Name = "DevOps-Jira-Server"
  }

  volume_tags = {
    Name = "DevOps-Jira-Server"
  }
}

# Define Confluence Server inside the private subnet
resource "aws_instance" "confluence" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.confluence.id
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_confluence.sh")}  

  tags = {
    Name = "DevOps-Confluence-Server"
  }

  volume_tags = {
    Name = "DevOps-Confluence-Server"
  }
}

# Define GitLab Server inside the private subnet
resource "aws_instance" "gitlab" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.gitlab.id
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_gitlab.sh")}"

  tags = {
    Name = "DevOps-GitLab-Server"
  }

  volume_tags = {
    Name = "DevOps-GitLab-Server"
  }
}

# Define Grafana Server inside the private subnet
resource "aws_instance" "grafana" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.grafana.id
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_grafana.sh")}"

  tags = {
    Name = "DevOps-Grafana-Server"
  }

  volume_tags = {
    Name = "DevOps-Grafana-Server"
  }
}

# Define Zabbix Server inside the private subnet
resource "aws_instance" "zabbix" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.zabbix.id
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_zabbix.sh")}"

  tags = {
    Name = "DevOps-Zabbix-Server"
  }

  volume_tags = {
    Name = "DevOps-Zabbix-Server"
  }
}

# Define OpenLDAP Server inside the private subnet
resource "aws_instance" "openldap" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.openldap.id
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_openldap.sh")}"

  tags = {
    Name = "DevOps-OpenLDAP-Server"
  }

  volume_tags = {
    Name = "DevOps-OpenLDAP-Server"
  }
}
