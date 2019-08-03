# Define Subnet Group for DB
resource "aws_db_subnet_group" "default" {
  name        = var.project_name != "" ? lower("${var.project_name}_db_subnet_group") : "db_subnet_group"
  description = "Group of private subnets"
  subnet_ids  = [aws_subnet.private1-subnet.id, aws_subnet.private2-subnet.id]
}

# Define SonarQube Database
resource "aws_db_instance" "sonarqube" {
  depends_on             = ["aws_security_group.sgdb"]
  identifier             = var.project_name != "" ? lower("${var.project_name}-${var.sonar_identifier}") : var.sonar_identifier
  allocated_storage      = var.sonar_storage
  engine                 = var.sonar_engine
  engine_version         = lookup(var.sonar_engine_version, var.sonar_engine)
  instance_class         = var.sonar_instance_class
  name                   = var.sonar_db_name
  username               = var.sonar_username
  password               = var.sonar_password
  vpc_security_group_ids = [aws_security_group.sgdb.id]
  db_subnet_group_name   = aws_db_subnet_group.default.id
  skip_final_snapshot    = true
  apply_immediately      = true
}
