# Define Jira Server inside the private subnet
resource "aws_instance" "keycloak" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  user_data     = var.install_script

  network_interface {
    network_interface_id = var.network_interface
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Keycloak-Server" : "Keycloak-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Keycloak-Server" : "Keycloak-Server"
  }
#   provisioner "file" {
#   #  source      = var.config_file
#     source      = "/tmp/test.txt"  
#     destination = "/tmp/"
#     connection {
#       user                = "ec2-user"
#       host                = aws_instance.keycloak.private_ip
#       private_key         = file(var.private_key)
#       bastion_host        = var.bastion_public_ip
#       bastion_host_key    = file(var.bastion_key)
#       bastion_private_key = file(var.bastion_private_key)
#     }
#   }

}


