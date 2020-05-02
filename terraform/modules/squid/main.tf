# Define Squid Server inside the public subnet
resource "aws_instance" "squid" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
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
      user                = var.remote_user
      host                = aws_instance.squid.private_ip
      private_key         = file(var.private_key)
      bastion_host        = var.bastion_host
      bastion_host_key    = file(var.bastion_host_key)
      bastion_private_key = file(var.bastion_private_key)
    }
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Squid-Server" : "Squid-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Squid-Server" : "Squid-Server"
  }
}

# Define network interface for Squid Server
resource "aws_network_interface" "squid" {
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgsquid.id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Squid-Server" : "Squid-Server"
  }
}


# Define the security group for Squid
resource "aws_security_group" "sgsquid" {
  name        = var.project_name != "" ? "${var.project_name}-Squid-SG" : "Squid-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Squid-Server-SG" : "Squid-Server-SG"
  }

  ingress {
    from_port = 8080
    to_port   = 8080
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
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "${var.bastion_private_ip}/32",
    ]
  }

  ingress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow response from another server to NginX Server"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH response from Bastion Server to another server"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH response from Bastion Server to another server"
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
    description = "Allow response from Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}


# Squid
data "template_file" "squid_install" {
  template = file("../scripts/install_squid.sh.tpl")

  vars = {
    squid_password = var.squid_password
    squid_username = var.squid_username
  }
}

resource "template_dir" "squid_config" {
  source_dir      = "../configs/squid/"
  destination_dir = "../configs/squid/conf.render/"

  vars = {
    public_ip_range       = var.public_subnet_cidr
    application1_ip_range = var.application1_subnet_cidr
    application2_ip_range = var.application2_subnet_cidr
    agent1_ip_range       = var.agent1_subnet_cidr
    agent2_ip_range       = var.agent2_subnet_cidr
    squid_port            = var.squid_port
  }
}
