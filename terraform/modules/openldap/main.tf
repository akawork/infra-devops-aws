# Define OpenLDAP Server inside the private subnet
resource "aws_instance" "openldap" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.openldap.id
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_openldap.sh")}"

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server" : "OpenLDAP-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server" : "OpenLDAP-Server"
  }
}
