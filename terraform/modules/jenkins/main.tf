# Define Jenkins Server inside the private subnet
resource "aws_instance" "jenkins" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair

  network_interface {
    network_interface_id = var.network_interface
    device_index         = 0
  }

  user_data = file(var.install_script)

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jenkins-Server" : "Jenkins-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jenkins-Server" : "Jenkins-Server"
  }
}
