# Define Jira Server inside the private subnet
resource "aws_instance" "jira" {
  depends_on    = ["aws_db_instance.jira"]
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = var.install_script

  network_interface {
    network_interface_id = var.network_interface
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jira-Server" : "Jira-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jira-Server" : "Jira-Server"
  }

  # Copies the dbconfig file to jira instance.
  provisioner "file" {
    source      = var.config_file
    destination = "/tmp/"
    connection {
      user                = "ec2-user"
      host                = aws_instance.jira.private_ip
      private_key         = file(var.private_key)
      bastion_host        = var.bastion_public_ip
      bastion_host_key    = file(var.bastion_key)
      bastion_private_key = file(var.bastion_private_key)
    }
  }
}

# Define Jira Database  
resource "aws_db_instance" "jira" {
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
}
