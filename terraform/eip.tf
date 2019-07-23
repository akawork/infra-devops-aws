# Define EIP for NAT gateway
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "DevOps NAT Gateway IP"
  }
}

# Define EIP for NAT gateway
resource "aws_eip" "nginx" {
  vpc = true

  tags = {
    Name = "DevOps NginX IP"
  }
}

resource "aws_eip_association" "eip_assoc_nginx" {
  instance_id   = aws_instance.nginx.id
  allocation_id = aws_eip.nginx.id
}
