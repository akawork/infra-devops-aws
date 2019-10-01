# Define NAT Instance Server inside the public subnet
resource "aws_instance" "nat_instance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair

  network_interface {
    network_interface_id = var.network_interface
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NAT-Server" : "NAT-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-NAT-Server" : "NAT-Server"
  }
}