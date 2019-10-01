# Define Squid Server inside the public subnet
resource "aws_instance" "squid" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = var.install_script

  network_interface {
    network_interface_id = var.network_interface
    device_index         = 0
  }

  # Copies the squid config files to /etc/squid.
  provisioner "file" {
    source      = var.squid_config
    destination = "/tmp/"
    connection {
      user                = "ec2-user"
      host                = aws_instance.squid.private_ip
      private_key         = file(var.internal_private_key_path)
      bastion_host        = aws_instance.bastion-server.public_ip
      bastion_host_key    = file(var.bastion_key_path)
      bastion_private_key = file(var.bastion_private_key_path)
    }
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Squid-Server" : "Squid-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Squid-Server" : "Squid-Server"
  }
}