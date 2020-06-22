# Define Bastion inside the public subnet
resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = data.template_file.bastion_config.rendered

  network_interface {
    network_interface_id = aws_network_interface.bastion.id
    device_index         = 0
  }

  # Copies the internal-key to /home/ec2-user
  provisioner "file" {
    source      = var.internal_private_key_path
    destination = "/home/${var.remote_user}/${var.internal_ssh_key_name}"
    connection {
      user        = var.remote_user
      host        = self.public_ip
      private_key = file(var.bastion_private_key_path)
    }
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bastion-Server" : "Bastion-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bastion-Server" : "Bastion-Server"
  }
}

# Define network interface for Bastion Server
resource "aws_network_interface" "bastion" {
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgbastion.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bastion-Server" : "Bastion-Server"
  }
}

# Define the security group for public subnet
resource "aws_security_group" "sgbastion" {
  name        = var.project_name != "" ? "${var.project_name}-Bastion-SG" : "Bastion-SG"
  description = "Allow SSH access on Bastion Server"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bastion-Server-SG" : "Bastion-Server-SG"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access on Bastion Server"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access on Bastion Server"
  }

#   ingress {
#     from_port = 32768
#     to_port   = 65535
#     protocol  = "tcp"
#     cidr_blocks = [
#       var.application1_subnet_cidr,
#       var.application2_subnet_cidr,
#       var.public_subnet_cidr,
#       var.agent1_subnet_cidr,
#       var.agent2_subnet_cidr,
#     ]
#     description = "Allow SSH response from Another Server in VPC to Bastion server"
#   }

  egress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
    ]
    description = "Allow SSH access from Bastion Server to another server in VPC"
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.squid_ip}/32"]
    description = "Allow access to internet via proxy server from Bastion Server"
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH response from Bastion Server to another server"
  }
}

# Bastion
data "template_file" "bastion_config" {
  template = file("../scripts/config_bastion.sh.tpl")

  vars = {
    squid_password        = var.squid_password
    squid_username        = var.squid_username
    squid_ip              = var.squid_ip
    squid_port            = var.squid_port
    remote_user           = var.remote_user
    internal_ssh_key_name = var.internal_ssh_key_name
  }
}
