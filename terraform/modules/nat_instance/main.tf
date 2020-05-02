# Define NAT Instance Server inside the public subnet
resource "aws_instance" "nat_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair

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

# Define network interface for NAT Server
resource "aws_network_interface" "nat_instance" {
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgnat.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NAT-Server" : "NAT-Server"
  }
}


# Define the security group for NAT Instance
resource "aws_security_group" "sgnat" {
  name        = var.project_name != "" ? "${var.project_name}-NAT-SG" : "NAT-SG"
  description = "Allow incoming HTTP/HTTPS connections & SSH access"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NAT-Instance-SG" : "NAT-Instance-SG"
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
    ]
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
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
      "${var.bastion_private_ip}/32",
    ]
    description = "Allow response port from NAT Server to another server"
  }
}
