# Define Bitbucket Server inside the private subnet
resource "aws_instance" "bitbucket" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = var.install_script
  depends_on    = [aws_db_instance.bitbucket]

  network_interface {
    network_interface_id = var.network_interface
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
    source      = var.bitbucket_config
    destination = "/tmp/"
    connection {
      user                = var.remote_user
      host                = aws_instance.bitbucket.private_ip
      private_key         = file(var.private_key)
      bastion_host        = var.bastion_host
      bastion_host_key    = file(var.bastion_host_key)
      bastion_private_key = file(var.bastion_private_key)
    }
  }
}

# Define Bitbucket Database
resource "aws_db_instance" "bitbucket" {
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
