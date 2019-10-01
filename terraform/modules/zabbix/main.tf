# Define Zabbix Server inside the private subnet
resource "aws_instance" "zabbix" {
  ami           = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = aws_key_pair.internal.id

  network_interface {
    network_interface_id = aws_network_interface.zabbix.id
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
