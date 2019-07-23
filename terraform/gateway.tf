# Define the internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops.id

  tags = {
    Name = "DevOps-IGW"
  }
}

# Define the NAT gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "DevOps-NAT-GW"
  }
}
