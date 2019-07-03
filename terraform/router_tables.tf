# Define the route table
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.devops.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "DevOps-Public-Router-Table"
  }
}

# Define the route table
resource "aws_route_table" "nat-rt" {
  vpc_id = "${aws_vpc.devops.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.natgw.id}"
  }

  tags = {
    Name = "DevOps-NAT-Router-Table"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "public-rt" {
  subnet_id      = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

# Assign the route table to the application1 Subnet
resource "aws_route_table_association" "application1-rt" {
  subnet_id      = "${aws_subnet.application1-subnet.id}"
  route_table_id = "${aws_route_table.nat-rt.id}"
}

# Assign the route table to the application2 Subnet
resource "aws_route_table_association" "application2-rt" {
  subnet_id      = "${aws_subnet.application2-subnet.id}"
  route_table_id = "${aws_route_table.nat-rt.id}"
}
