# Define Nexus Server inside the private subnet
resource "aws_instance" "nexus" {
  ami           = var.amis[var.region]
  instance_type = "t2.medium"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.nexus.id
    device_index         = 0
  }

  user_data = data.template_file.nexus_properties.rendered

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server" : "Nexus-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server" : "Nexus-Server"
  }
}