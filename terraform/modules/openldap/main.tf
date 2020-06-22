# Define OpenLDAP Server inside the private subnet
resource "aws_instance" "openldap" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  #  user_data = "${file("./scripts/install_openldap.sh")}"
  count         = var.enable == "true" ? 1 : 0

  network_interface {
    network_interface_id = aws_network_interface.openldap[0].id
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server" : "OpenLDAP-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server" : "OpenLDAP-Server"
  }
}

# Define network interface for OpenLDAP Server
resource "aws_network_interface" "openldap" {
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgopenldap[0].id]
  source_dest_check = false
  count             = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server" : "OpenLDAP-Server"
  }
}

# Define the security group for OpenLDAP
resource "aws_security_group" "sgopenldap" {
  name        = "DevOps_OpenLDAP_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = var.vpc_id
  count       = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server-SG" : "OpenLDAP-Server-SG"
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

