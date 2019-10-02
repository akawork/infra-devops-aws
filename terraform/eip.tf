# Define EIP for NAT gateway
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NAT-Gateway-IP" : "NAT-Gateway-IP"
  }
}

# Define EIP for NAT gateway
resource "aws_eip" "nginx" {
  vpc = true

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NginX-IP" : "NginX-IP"
  }
}

resource "aws_eip_association" "eip_assoc_nginx" {
  instance_id   = module.nginx.instance_id
  allocation_id = aws_eip.nginx.id
}
