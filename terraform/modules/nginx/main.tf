# Define NginX Server inside the public subnet
resource "aws_instance" "nginx" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = file(var.install_script)

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
      user                = var.remote_user
      host                = aws_instance.nginx.private_ip
      private_key         = file(var.private_key)
      bastion_host        = var.bastion_host
      bastion_host_key    = file(var.bastion_host_key)
      bastion_private_key = file(var.bastion_private_key)
    }
  }

  provisioner "file" {
    source      = var.nginx_config
    destination = "/tmp/nginx.conf"
    connection {
      user                = var.remote_user
      host                = aws_instance.nginx.private_ip
      private_key         = file(var.private_key)
      bastion_host        = var.bastion_host
      bastion_host_key    = file(var.bastion_host_key)
      bastion_private_key = file(var.bastion_private_key)
    }
  }
}

# Define network interface for Nginx Server
resource "aws_network_interface" "nginx" {
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgnginx.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nginx-Server" : "Nginx-Server"
  }
}


# Define the security group for NginX
resource "aws_security_group" "sgnginx" {
  name        = var.project_name != "" ? "${var.project_name}-NginX-SG" : "NginX-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NginX-Server-SG" : "NginX-Server-SG"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.bastion_private_ip}/32"]
  }

  ingress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
    ]
    description = "Allow response from another server to NginX Server"
  }

  egress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
    ]
    description = "Allow SSH response from Bastion Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow response from NginX Server to another server"
  }
}

# Nginx
resource "template_dir" "nginx_conf" {
  source_dir      = "../configs/nginx/conf.d/"
  destination_dir = "../configs/nginx/conf.render/"

  vars = {
    jenkins_domain_name    = "jenkins.${var.domain_name}" 
    sonar_domain_name      = "sonar.${var.domain_name}"
    nexus_domain_name      = "nexus.${var.domain_name}"
    gitlab_domain_name     = "gitlab.${var.domain_name}"
    jira_domain_name       = "jira.${var.domain_name}"
    confluence_domain_name = "confluence.${var.domain_name}"
    monitor_domain_name    = "monitor.${var.domain_name}"
    bitbucket_domain_name  = "bitbucket.${var.domain_name}"
    monitor_ip             = var.monitor_ip
    jenkins_ip             = var.jenkins_ip
    sonar_ip               = var.sonar_ip
    nexus_ip               = var.nexus_ip
    gitlab_ip              = var.gitlab_ip
    jira_ip                = var.jira_ip
    confluence_ip          = var.confluence_ip
    bitbucket_ip          = var.bitbucket_ip
  }
}
