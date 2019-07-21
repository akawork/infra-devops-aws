# Define subnets in VPC
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.devops.id
  availability_zone       = var.az_1
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "DevOps-Public-Subnet"
  }
}

resource "aws_subnet" "application1-subnet" {
  vpc_id                  = aws_vpc.devops.id
  availability_zone       = var.az_1
  cidr_block              = var.application1_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "DevOps-Application1-Subnet"
  }
}

resource "aws_subnet" "application2-subnet" {
  vpc_id                  = aws_vpc.devops.id
  availability_zone       = var.az_1
  cidr_block              = var.application2_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "DevOps-Application2-Subnet"
  }
}

resource "aws_subnet" "private1-subnet" {
  vpc_id                  = aws_vpc.devops.id
  availability_zone       = var.az_1
  cidr_block              = var.private1_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "DevOps-Private1-Subnet"
  }
}

resource "aws_subnet" "private2-subnet" {
  vpc_id                  = aws_vpc.devops.id
  availability_zone       = var.az_1
  cidr_block              = var.private2_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "DevOps-Private2-Subnet"
  }
}

resource "aws_subnet" "agent1-subnet" {
  vpc_id                  = aws_vpc.devops.id
  availability_zone       = var.az_1
  cidr_block              = var.agent1_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "DevOps-Agent1-Subnet"
  }
}

resource "aws_subnet" "agent2-subnet" {
  vpc_id                  = aws_vpc.devops.id
  availability_zone       = var.az_1
  cidr_block              = var.agent2_subnet_cidr
  map_public_ip_on_launch = false

  tags = {
    Name = "DevOps-Agent2-Subnet"
  }
}
