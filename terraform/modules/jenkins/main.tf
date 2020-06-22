# Define Jenkins Server inside the private subnet
resource "aws_instance" "jenkins" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = data.template_file.jenkins_install[0].rendered
  count         = var.enable == "true" ? 1 : 0

  network_interface {
    network_interface_id = aws_network_interface.jenkins[0].id
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jenkins-Server" : "Jenkins-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jenkins-Server" : "Jenkins-Server"
  }
}

# Define domain name 
resource "aws_route53_record" "jenkins" {
  zone_id = var.route53_zone_id
  name    = "jenkins.${var.route53_name}"
  type    = "A"
  ttl     = "300"
  records = [var.nginx_public_ip]
  count   = var.enable == "true" ? 1 : 0
}

# Define network interface for Jenkins Server
resource "aws_network_interface" "jenkins" {
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgjenkins[0].id]
  source_dest_check = false
  count             = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jenkins-Server" : "Jenkins-Server"
  }
}


# Define the security group for Jenkins
resource "aws_security_group" "sgjenkins" {
  name        = var.project_name != "" ? "${var.project_name}-Jenkins-SG" : "Jenkins-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = var.vpc_id
  count   = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jenkins-Server-SG" : "Jenkins-Server-SG"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.nginx_private_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.bastion_private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${var.nginx_private_ip}/32",
      "${var.bastion_private_ip}/32",
    ]
    description = "Allow response port from Nexus Server to another server"
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

data "template_file" "jenkins_install" {
  template = file("../scripts/install_jenkins.sh.tpl")
  count    = var.enable == "true" ? 1 : 0

  vars = {
    jenkins_version = var.jenkins_version
  }
}

# data "external" "admin_passwd" {
#   count   = var.enable == "true" ? 1 : 0
#   program = ["cat", "/var/lib/jenkins/secrets/initialAdminPassword"]
# }
