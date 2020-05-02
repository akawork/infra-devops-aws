# Define Prometheus Server inside the private subnet
resource "aws_instance" "prometheus" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = data.template_file.prometheus_install[0].rendered
  count         = var.enable == "true" ? 1 : 0

  network_interface {
    network_interface_id = aws_network_interface.prometheus[0].id
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Prometheus-Server" : "Prometheus-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Prometheus-Server" : "Prometheus-Server"
  }

  # Copies the config file to prometheus instance.
  provisioner "file" {
    source      = template_dir.prometheus_config[0].destination_dir
    destination = "/tmp/"
    connection {
      user                = var.remote_user
      host                = aws_instance.prometheus[0].private_ip
      private_key         = file(var.private_key)
      bastion_host        = var.bastion_host
      bastion_host_key    = file(var.bastion_host_key)
      bastion_private_key = file(var.bastion_private_key)
    }
  }
}

# Define network interface for Prometheus Server
resource "aws_network_interface" "prometheus" {
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgprometheus[0].id]
  source_dest_check = false
  count             = var.enable == "true" ? 1 : 0 

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Prometheus-Server" : "Prometheus-Server"
  }
}


# Define the security group for Prometheus
resource "aws_security_group" "sgprometheus" {
  name        = "DevOps_Prometheus_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = var.vpc_id
  count       = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Prometheus-Server-SG" : "Prometheus-Server-SG"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
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
    description = "Allow response port from Prometheus Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}


# Template for Prometheus installation 
data "template_file" "prometheus_install" {
  template = file("../scripts/install_prometheus.sh.tpl")
  count    = var.enable == "true" ? 1 : 0

  vars = {
    prometheus_version = var.prometheus_version
  }
}

resource "template_dir" "prometheus_config" {
  source_dir      = "../configs/prometheus/"
  destination_dir = "../configs/prometheus/conf.render/"
  count           = var.enable == "true" ? 1 : 0

  vars = {
    prometheus_url = "localhost:9090"
  }
}
