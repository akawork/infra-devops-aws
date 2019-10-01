# Define Prometheus Server inside the private subnet
resource "aws_instance" "prometheus" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.prometheus.id
    device_index         = 0
  }

  user_data = data.template_file.prometheus_install.rendered

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Prometheus-Server" : "Prometheus-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Prometheus-Server" : "Prometheus-Server"
  }

  # Copies the config file to prometheus instance.
  provisioner "file" {
    source      = template_dir.prometheus_config.destination_dir
    destination = "/tmp/"
    connection {
      user                = "ec2-user"
      host                = aws_instance.prometheus.private_ip
      private_key         = file(var.internal_private_key_path)
      bastion_host        = aws_instance.bastion-server.public_ip
      bastion_host_key    = file(var.bastion_key_path)
      bastion_private_key = file(var.bastion_private_key_path)
    }
  }
}
