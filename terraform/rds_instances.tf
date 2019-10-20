# Define Subnet Group for DB
resource "aws_db_subnet_group" "default" {
  name        = var.project_name != "" ? lower("${var.project_name}_db_subnet_group") : "db_subnet_group"
  description = "Group of private subnets"
  subnet_ids  = [aws_subnet.private1-subnet.id, aws_subnet.private2-subnet.id]
}

# Define GitLab Database
resource "aws_db_instance" "gitlab" {
  depends_on             = ["aws_security_group.sgdb"]
  identifier             = var.project_name != "" ? lower("${var.project_name}-${var.gitlab_identifier}") : var.gitlab_identifier
  allocated_storage      = var.gitlab_storage
  engine                 = var.gitlab_engine
  engine_version         = lookup(var.gitlab_engine_version, var.gitlab_engine)
  instance_class         = var.gitlab_instance_class
  name                   = var.gitlab_db_name
  username               = var.gitlab_username
  password               = var.gitlab_password
  vpc_security_group_ids = [aws_security_group.sgdb.id]
  db_subnet_group_name   = aws_db_subnet_group.default.id
  skip_final_snapshot    = true
  apply_immediately      = true
}

# Define Jira Database  
resource "aws_db_instance" "jira" {
  depends_on             = ["aws_security_group.sgdb"]
  identifier             = var.project_name != "" ? lower("${var.project_name}-${var.jira_identifier}") : var.jira_identifier
  allocated_storage      = var.jira_storage
  engine                 = var.jira_engine
  engine_version         = lookup(var.jira_engine_version, var.jira_engine)
  instance_class         = var.jira_instance_class
  name                   = var.jira_db_name
  username               = var.jira_username
  password               = var.jira_password
  vpc_security_group_ids = [aws_security_group.sgdb.id]
  db_subnet_group_name   = aws_db_subnet_group.default.id
  skip_final_snapshot    = true
  apply_immediately      = true
}

# Define Confluence Database  
resource "aws_db_instance" "confluence" {
  depends_on             = ["aws_security_group.sgdb"]
  identifier             = var.project_name != "" ? lower("${var.project_name}-${var.confluence_identifier}") : var.confluence_identifier
  allocated_storage      = var.confluence_storage
  engine                 = var.confluence_engine
  engine_version         = lookup(var.confluence_engine_version, var.confluence_engine)
  instance_class         = var.confluence_instance_class
  name                   = var.confluence_db_name
  username               = var.confluence_username
  password               = var.confluence_password
  vpc_security_group_ids = [aws_security_group.sgdb.id]
  db_subnet_group_name   = aws_db_subnet_group.default.id
  skip_final_snapshot    = true
  apply_immediately      = true
}
