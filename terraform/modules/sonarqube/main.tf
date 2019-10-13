# Define Sonarqube Server inside the private subnet
resource "aws_instance" "sonarqube" {
  depends_on    = [aws_db_instance.sonarqube]
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = var.install_script

  network_interface {
    network_interface_id = var.network_interface
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
  depends_on             = [var.sgdb]
  identifier             = var.project_name != "" ? lower("${var.project_name}-${var.sonar_identifier}") : var.sonar_identifier
  allocated_storage      = var.sonar_storage
  engine                 = var.sonar_engine
  engine_version         = lookup(var.sonar_engine_version, var.sonar_engine)
  instance_class         = var.sonar_instance_class
  name                   = var.sonar_db_name
  username               = var.sonar_username
  password               = var.sonar_password
  vpc_security_group_ids = [var.sgdb.id]
  db_subnet_group_name   = var.db_subnet_group_name
  skip_final_snapshot    = true
  apply_immediately      = true
}
