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
