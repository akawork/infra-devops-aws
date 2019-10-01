# Define webserver inside the public subnet
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
      bastion_host_key    = file(var.bastion_key_path)
      bastion_private_key = file(var.bastion_private_key_path)
    }
  }
}
