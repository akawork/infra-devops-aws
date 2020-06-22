# Define Sonarqube Server inside the private subnet
resource "aws_instance" "sonarqube" {
  depends_on    = [aws_db_instance.sonarqube]
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = data.template_file.sonar_properties[0].rendered
  count         = var.enable == "true" ? 1 : 0

  network_interface {
    network_interface_id = aws_network_interface.sonar[0].id
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Sonarqube-Server" : "Sonarqube-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Sonarqube-Server" : "Sonarqube-Server"
  }
}

# Define SonarQube Database
resource "aws_db_instance" "sonarqube" {
  depends_on             = [var.db_security_group]
  identifier             = var.project_name != "" ? lower("${var.project_name}-${var.db_identifier}") : var.db_identifier
  allocated_storage      = var.db_storage
  engine                 = var.db_engine
  engine_version         = lookup(var.db_engine_version, var.db_engine)
  instance_class         = var.db_instance_class
  name                   = var.db_name
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [var.db_security_group.id]
  db_subnet_group_name   = var.db_subnet_group_name
  skip_final_snapshot    = true
  apply_immediately      = true
  count                  = var.enable == "true" ? 1 : 0
}

resource "aws_route53_record" "sonar" {
  zone_id = var.route53_zone_id
  name    = "sonar.${var.route53_name}"
  type    = "A"
  ttl     = "300"
  records = [var.nginx_public_ip]
  count   = var.enable == "true" ? 1 : 0
}

# Define network interface for Sonar Server
resource "aws_network_interface" "sonar" {
  subnet_id         = var.subnet_id
  private_ips       = [var.ip_address]
  security_groups   = [aws_security_group.sgsonar[0].id]
  source_dest_check = false
  count             = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Sonar-Server" : "Sonar-Server"
  }
}

# Define the security group for Sonar
resource "aws_security_group" "sgsonar" {
  name        = var.project_name != "" ? "${var.project_name}-Sonar-SG" : "Sonar-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = var.vpc_id
  count       = var.enable == "true" ? 1 : 0

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Sonar-Server-SG" : "Sonar-Server-SG"
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
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
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.private1_subnet_cidr,
      var.private2_subnet_cidr,
    ]
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# SonarQube
data "template_file" "sonar_properties" {
  template = file("../scripts/install_sonar.sh.tpl")
  count    = var.enable == "true" ? 1 : 0

  vars = {
    db_endpoint   = aws_db_instance.sonarqube[0].endpoint
    db_name       = var.db_name
    db_password   = var.db_password
    db_username   = var.db_username
    sonar_version = var.sonar_version
  }
}
