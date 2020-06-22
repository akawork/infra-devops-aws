# Define Nexus Server inside the private subnet
resource "aws_instance" "nexus" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = data.template_file.nexus_install[0].rendered
  count         = var.enable == "true" ? 1 : 0

  network_interface {
    network_interface_id = aws_network_interface.nexus[0].id
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server" : "Nexus-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server" : "Nexus-Server"
  }
}

# Define domain name
resource "aws_route53_record" "nexus" {
  zone_id = var.route53_zone_id
  name    = "nexus.${var.route53_name}"
  type    = "A"
  ttl     = "300"
  records = [var.nginx_public_ip]
  count   = var.enable == "true" ? 1 : 0
}

# Define network interface for Nexus Server
resource "aws_network_interface" "nexus" {
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgnexus[0].id]
  source_dest_check = false
  count             = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server" : "Nexus-Server"
  }
}

# Define the security group for Nexus
resource "aws_security_group" "sgnexus" {
  name        = var.project_name != "" ? "${var.project_name}-Nexus-SG" : "Nexus-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = var.vpc_id
  count       = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server-SG" : "Nexus-Server-SG"
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
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

# Template install nexus
data "template_file" "nexus_install" {
  template = file("../scripts/install_nexus.sh.tpl")
  count       = var.enable == "true" ? 1 : 0

  vars = {
    nexus_version = var.nexus_version
  }
}
