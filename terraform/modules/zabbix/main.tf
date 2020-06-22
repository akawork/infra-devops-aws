# Define Zabbix Server inside the private subnet
resource "aws_instance" "zabbix" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  count         = var.enable == "true" ? 1 : 0

  network_interface {
    network_interface_id = aws_network_interface.zabbix[0].id
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

# Define network interface for Zabbix Server
resource "aws_network_interface" "zabbix" {
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgzabbix[0].id]
  source_dest_check = false
  count             = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Zabbix-Server" : "Zabbix-Server"
  }
}


# Define the security group for Zabbix
resource "aws_security_group" "sgzabbix" {
  name        = "DevOps_Zabbix_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = var.vpc_id
  count       = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Zabbix-Server-SG" : "Zabbix-Server-SG"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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
    description = "Allow response port from Zabbix Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}
