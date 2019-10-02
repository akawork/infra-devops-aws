# Define Zabbix Server inside the private subnet
resource "aws_instance" "zabbix" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_pair

  network_interface {
    network_interface_id = var.network_interface
    device_index         = 0
  }

  #  user_data = "${file("./scripts/install_zabbix.sh")}"

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Zabbix-Server" : "Zabbix-Server"
  }

  volume_tags = {
    Name = var.project_name != "" ? "${var.project_name}-Zabbix-Server" : "Zabbix-Server"
  }
}
