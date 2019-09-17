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
  user_data     = data.template_file.bastion_config.rendered

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

  # Copies the SSH config files to /etc/ssh.
  provisioner "file" {
    source      = template_dir.bastion_ssh_config.destination_dir
    destination = "/tmp/"
    connection {
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file(var.bastion_private_key_path)
    }
  }

  network_interface {
    network_interface_id = aws_network_interface.bastion.id
    device_index         = 0
  }

  # provisioner "local-exec" {
  #   command = "chmod -R 400 internal-key"
  #   interpreter = ["/bin/bash", "-c"]
  # }

  # provisioner "local-exec" {
  #   command = "sudo su"
  # }

  # provisioner "local-exec" {
  #   command = "sudo sed -i 's/#Port 22/Port 443/g' /etc/ssh/sshd_config"
  # }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bastion-Server" : "Bastion-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bastion-Server" : "Bastion-Server"
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
    Name = var.project_name != "" ? "${var.project_name}-NAT-Server" : "NAT-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-NAT-Server" : "NAT-Server"
  }
}

# Define Squid Server inside the public subnet
resource "aws_instance" "squid" {
  ami           = var.amis[var.region]
  instance_type = "t2.nano"
  key_name      = aws_key_pair.internal.id
  user_data     = data.template_file.squid_install.rendered

  network_interface {
    network_interface_id = aws_network_interface.squid.id
    device_index         = 0
  }

  # Copies the squid config files to /etc/squid.
  provisioner "file" {
    source      = template_dir.squid_config.destination_dir
    destination = "/tmp/"
    connection {
      user                = "ec2-user"
      host                = aws_instance.squid.private_ip
      private_key         = file(var.internal_private_key_path)
      bastion_host        = aws_instance.bastion-server.public_ip
      bastion_port        = var.bastion_ssh_port
      bastion_host_key    = file(var.bastion_key_path)
      bastion_private_key = file(var.bastion_private_key_path)
    }
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Squid-Server" : "Squid-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Squid-Server" : "Squid-Server"
  }
}

# Define NginX Server inside the public subnet
resource "aws_instance" "nginx" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id
  user_data     = file("../scripts/install_nginx.sh")

  network_interface {
    network_interface_id = aws_network_interface.nginx.id
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NginX-Server" : "NginX-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-NginX-Server" : "NginX-Server"
  }

  # Copies the nginx config files to /etc/nginx.
  provisioner "file" {
    source      = template_dir.nginx_conf.destination_dir
    destination = "/tmp/"
    connection {
      user                = "ec2-user"
      host                = aws_instance.nginx.private_ip
      private_key         = file(var.internal_private_key_path)
      bastion_host        = aws_instance.bastion-server.public_ip
      bastion_port        = var.bastion_ssh_port
      bastion_host_key    = file(var.bastion_key_path)
      bastion_private_key = file(var.bastion_private_key_path)
    }
  }

  provisioner "file" {
    source      = "../configs/nginx/nginx.conf"
    destination = "/tmp/nginx.conf"
    connection {
      user                = "ec2-user"
      host                = aws_instance.nginx.private_ip
      private_key         = file(var.internal_private_key_path)
      bastion_host        = aws_instance.bastion-server.public_ip
      bastion_port        = var.bastion_ssh_port
      bastion_host_key    = file(var.bastion_key_path)
      bastion_private_key = file(var.bastion_private_key_path)
    }
  }
}

# Define Nexus Server inside the private subnet
resource "aws_instance" "nexus" {
  ami           = var.amis[var.region]
  instance_type = "t2.medium"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.nexus.id
    device_index         = 0
  }

  user_data = data.template_file.nexus_properties.rendered

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server" : "Nexus-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server" : "Nexus-Server"
  }
}

# Define Sonarqube Server inside the private subnet
resource "aws_instance" "sonarqube" {
  depends_on    = ["aws_db_instance.sonarqube"]
  ami           = var.amis[var.region]
  instance_type = "t2.medium"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.sonar.id
    device_index         = 0
  }

  user_data = data.template_file.sonar_properties.rendered

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Sonarqube-Server" : "Sonarqube-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Sonarqube-Server" : "Sonarqube-Server"
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

  user_data = file("../scripts/install_jenkins.sh")

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jenkins-Server" : "Jenkins-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jenkins-Server" : "Jenkins-Server"
  }
}

# Define Jira Server inside the private subnet
resource "aws_instance" "jira" {
  depends_on    = ["aws_db_instance.jira"]
  ami           = var.amis[var.region]
  instance_type = "t2.small"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.jira.id
    device_index         = 0
  }

  user_data = data.template_file.jira_properties.rendered

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jira-Server" : "Jira-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jira-Server" : "Jira-Server"
  }

  # Copies the dbconfig file to jira instance.
  provisioner "file" {
    source      = template_dir.jira_config.destination_dir
    destination = "/tmp/"
    connection {
      user                = "ec2-user"
      host                = aws_instance.jira.private_ip
      private_key         = file(var.internal_private_key_path)
      bastion_host        = aws_instance.bastion-server.public_ip
      bastion_port        = var.bastion_ssh_port
      bastion_host_key    = file(var.bastion_key_path)
      bastion_private_key = file(var.bastion_private_key_path)
    }
  }
}

# Define Confluence Server inside the private subnet
resource "aws_instance" "confluence" {
  depends_on    = ["aws_db_instance.confluence"]
  ami           = var.amis[var.region]
  instance_type = "t2.small"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.confluence.id
    device_index         = 0
  }

  user_data = data.template_file.confluence_properties.rendered

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Confluence-Server" : "Confluence-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Confluence-Server" : "Confluence-Server"
  }
}

# Define GitLab Server inside the private subnet
resource "aws_instance" "gitlab" {
  depends_on    = ["aws_db_instance.gitlab"]
  ami           = var.amis[var.region]
  instance_type = "t2.medium"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.gitlab.id
    device_index         = 0
  }

  user_data = data.template_file.gitlab_install.rendered

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-GitLab-Server" : "GitLab-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-GitLab-Server" : "GitLab-Server"
  }

  # Copies the gitlab file to /etc/gitlab.
  provisioner "file" {
    source      = template_dir.gitlab_config.destination_dir
    destination = "/tmp/"
    connection {
      user                = "ec2-user"
      host                = aws_instance.gitlab.private_ip
      private_key         = file(var.internal_private_key_path)
      bastion_host        = aws_instance.bastion-server.public_ip
      bastion_port        = var.bastion_ssh_port
      bastion_host_key    = file(var.bastion_key_path)
      bastion_private_key = file(var.bastion_private_key_path)
    }
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

  user_data = data.template_file.grafana_install.rendered

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Grafana-Server" : "Grafana-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Grafana-Server" : "Grafana-Server"
  }

  # Copies the config file to grafana instance.
  provisioner "file" {
    source      = template_dir.grafana_config.destination_dir
    destination = "/tmp/"
    connection {
      user                = "ec2-user"
      host                = aws_instance.grafana.private_ip
      private_key         = file(var.internal_private_key_path)
      bastion_host        = aws_instance.bastion-server.public_ip
      bastion_port        = var.bastion_ssh_port
      bastion_host_key    = file(var.bastion_key_path)
      bastion_private_key = file(var.bastion_private_key_path)
    }
  }
}

# Define Prometheus Server inside the private subnet
resource "aws_instance" "prometheus" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.prometheus.id
    device_index         = 0
  }

  user_data = data.template_file.prometheus_install.rendered

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Prometheus-Server" : "Prometheus-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Prometheus-Server" : "Prometheus-Server"
  }

  # Copies the config file to prometheus instance.
  provisioner "file" {
    source      = template_dir.prometheus_config.destination_dir
    destination = "/tmp/"
    connection {
      user                = "ec2-user"
      host                = aws_instance.prometheus.private_ip
      private_key         = file(var.internal_private_key_path)
      bastion_host        = aws_instance.bastion-server.public_ip
      bastion_port        = var.bastion_ssh_port
      bastion_host_key    = file(var.bastion_key_path)
      bastion_private_key = file(var.bastion_private_key_path)
    }
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
    Name = var.project_name != "" ? "${var.project_name}-Zabbix-Server" : "Zabbix-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Zabbix-Server" : "Zabbix-Server"
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
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server" : "OpenLDAP-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server" : "OpenLDAP-Server"
  }
}
