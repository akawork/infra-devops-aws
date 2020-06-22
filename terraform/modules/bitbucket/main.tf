# Define Bitbucket Server inside the private subnet
resource "aws_instance" "bitbucket" {
  ami           = var.ami
  count         = "${var.enable == "true" ? 1 : 0}"
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = data.template_file.bitbucket_install[0].rendered
  depends_on    = [aws_db_instance.bitbucket]

  network_interface {
    network_interface_id = aws_network_interface.bitbucket[0].id
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bitbucket-Server" : "Bitbucket-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bitbucket-Server" : "Bitbucket-Server"
  }

  # Copies the config file to Bitbucket instance.
  provisioner "file" {
    source      = template_dir.bitbucket_config[0].destination_dir
    destination = "/tmp/"
    connection {
      user                = var.remote_user
      host                = aws_instance.bitbucket[0].private_ip
      private_key         = file(var.private_key)
      bastion_host        = var.bastion_host
      bastion_host_key    = file(var.bastion_host_key)
      bastion_private_key = file(var.bastion_private_key)
    }
  }
}

# Define Bitbucket Database
resource "aws_db_instance" "bitbucket" {
  count                  = "${var.enable == "true" ? 1 : 0}"  
  depends_on             = [var.db_security_group]
  identifier             = var.db_identifier
  allocated_storage      = var.db_allocated_storage
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  name                   = var.db_name
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [var.db_security_group.id]
  db_subnet_group_name   = var.db_subnet_group_name
  skip_final_snapshot    = true
  apply_immediately      = true
}

resource "aws_route53_record" "bitbucket" {
  count   = "${var.enable == "true" ? 1 : 0}"
  zone_id = var.route53_zone_id
  name    = "bitbucket.${var.route53_name}"
  type    = "A"
  ttl     = "300"
  records = [var.nginx_public_ip]
}

# Define network interface for Bitbucket Server
resource "aws_network_interface" "bitbucket" {
  count             = "${var.enable == "true" ? 1 : 0}"
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgbitbucket[0].id]
  source_dest_check = false

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bitbucket-Server" : "Bitbucket-Server"
  }
}


# Define the security group for Bitbucket
resource "aws_security_group" "sgbitbucket" {
  count       = "${var.enable == "true" ? 1 : 0}"
  name        = var.project_name != "" ? "${var.project_name}-Bitbucket-SG" : "Bitbucket-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bitbucket-Server-SG" : "Bitbucket-Server-SG"
  }

  ingress {
    from_port   = 7990
    to_port     = 7990
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
    description = "Allow response port from Bitbucket Server to another server"
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.private1_subnet_cidr,
      var.private2_subnet_cidr,
    ]
    description = "Allow response port from Bitbucket Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Bitbucket
data "template_file" "bitbucket_install" {
  count    = "${var.enable == "true" ? 1 : 0}"
  template = file("../scripts/install_bitbucket.sh.tpl")

  vars = {
    bitbucket_version = var.bitbucket_version
  }
}

resource "template_dir" "bitbucket_config" {
  count           = "${var.enable == "true" ? 1 : 0}"
  source_dir      = "../configs/bitbucket/"
  destination_dir = "../configs/bitbucket/conf.render/"

  vars = {
    db_endpoint = aws_db_instance.bitbucket[0].endpoint
    db_name     = var.db_name
    db_password = var.db_password
    db_username = var.db_username
    domain_name = "bitbucket.${var.domain_name}"
  }
}
