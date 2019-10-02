# Define NginX Server inside the public subnet
resource "aws_instance" "nginx" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_pair
  user_data     = file(var.install_script)

  network_interface {
    network_interface_id = var.network_interface
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NginX-Server" : "NginX-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-NginX-Server" : "NginX-Server"
  }

  # Copies the nginx config files to /etc/nginx.
  provisioner "file" {
    source      = var.nginx_configd
    destination = "/tmp/"
    connection {
      user                = var.remote_user
      host                = aws_instance.nginx.private_ip
      private_key         = file(var.private_key)
      bastion_host        = var.bastion_host
      bastion_host_key    = file(var.bastion_host_key)
      bastion_private_key = file(var.bastion_private_key)
    }
  }

  provisioner "file" {
    source      = var.nginx_config
    destination = "/tmp/nginx.conf"
    connection {
      user                = var.remote_user
      host                = aws_instance.nginx.private_ip
      private_key         = file(var.private_key)
      bastion_host        = var.bastion_host
      bastion_host_key    = file(var.bastion_host_key)
      bastion_private_key = file(var.bastion_private_key)
    }
  }
}
