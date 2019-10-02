# Define Nexus Server inside the private subnet
resource "aws_instance" "nexus" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = var.install_script

  network_interface {
    network_interface_id = var.network_interface
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server" : "Nexus-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server" : "Nexus-Server"
  }
}