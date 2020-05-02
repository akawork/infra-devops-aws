# Define the security group for private subnet
resource "aws_security_group" "sgdb" {
  name        = var.project_name != "" ? "${var.project_name}-DB-SG" : "DB-SG"
  description = "Allow traffic from appplication subnet"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-DB-SG" : "DB-SG"
  }
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
    ]
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
    ]
  }
}
