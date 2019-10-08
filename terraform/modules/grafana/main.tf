# Define Grafana Server inside the private subnet
resource "aws_instance" "grafana" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = var.install_script

  network_interface {
    network_interface_id = var.network_interface
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Grafana-Server" : "Grafana-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Grafana-Server" : "Grafana-Server"
  }

  # Copies the config file to grafana instance.
  provisioner "file" {
    source      = var.grafana_config
    destination = "/tmp/"
    connection {
      user                = var.remote_user
      host                = aws_instance.grafana.private_ip
      private_key         = file(var.private_key)
      bastion_host        = var.bastion_host
      bastion_host_key    = file(var.bastion_host_key)
      bastion_private_key = file(var.bastion_private_key)
    }
  }
}
