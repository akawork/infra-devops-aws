# Define Grafana Server inside the private subnet
resource "aws_instance" "grafana" {
  ami           = var.ami
  count         = var.enable == "true" ? 1 : 0
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = data.template_file.grafana_install[0].rendered
  

  network_interface {
    network_interface_id = aws_network_interface.grafana[0].id
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
    source      = template_dir.grafana_config[0].destination_dir
    destination = "/tmp/"
    connection {
      bastion_host        = var.bastion_host
      bastion_host_key    = file(var.bastion_host_key)
      bastion_private_key = file(var.bastion_private_key)
      host                = aws_instance.grafana[0].private_ip
      private_key         = file(var.private_key)
      user                = var.remote_user
    }
  }
}

resource "aws_route53_record" "monitor" {
  count   = var.enable == "true" ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "monitor.${var.route53_name}"
  type    = "A"
  ttl     = "300"
  records = [var.nginx_public_ip]
}

# Define network interface for Grafana Server
resource "aws_network_interface" "grafana" {
  count             = var.enable == "true" ? 1 : 0
  private_ips       = [var.ip_address]
  subnet_id         = var.subnet_id
  security_groups   = [aws_security_group.sggrafana[0].id]
  source_dest_check = false
  

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Grafana-Server" : "Grafana-Server"
  }
}

# Define the security group for Grafana
resource "aws_security_group" "sggrafana" {
  count       = var.enable == "true" ? 1 : 0
  name        = "DevOps_Grafana_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Grafana-Server-SG" : "Grafana-Server-SG"
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
    description = "Allow response port from Grafana Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Grafana
data "template_file" "grafana_install" {
  template = file("../scripts/install_grafana.sh.tpl")
  count    = var.enable == "true" ? 1 : 0

  vars = {
    grafana_version = var.grafana_version
  }
}

resource "template_dir" "grafana_config" {
  source_dir      = "../configs/grafana/"
  destination_dir = "../configs/grafana/conf.render/"
  count           = var.enable == "true" ? 1 : 0

  vars = {
    prometheus_url = "http://${var.prometheus_ip}:9090"
  }
}
