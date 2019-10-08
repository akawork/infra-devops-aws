# Define OpenLDAP Server inside the private subnet
resource "aws_instance" "openldap" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair
  #  user_data = "${file("./scripts/install_openldap.sh")}"

  network_interface {
    network_interface_id = var.network_interface
    device_index         = 0
  }

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server" : "OpenLDAP-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server" : "OpenLDAP-Server"
  }
}
