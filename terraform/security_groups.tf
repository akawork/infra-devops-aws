# Define the security group for public subnet
resource "aws_security_group" "sgbastion" {
  name        = "DevOps-Bastion-SG"
  description = "Allow SSH access on Bastion Server"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-Bastion-Server-SG"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access on Bastion Server"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access on Bastion Server"
  }

  ingress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
    ]
    description = "Allow SSH resonse from Another Server in VPC to Bastion server"
  }

  egress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
    ]
    description = "Allow SSH access from Bastion Server to another server in VPC"
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH resonse from Bastion Server to another server"
  }
}

# Define the security group for NAT Instance
resource "aws_security_group" "sgnat" {
  name        = "DevOps-NAT-SG"
  description = "Allow incoming HTTP/HTTPS connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-NAT-Instance-SG"
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
    ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-server.private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse port from NAT Server to another server"
  }
}

# Define the security group for NginX
resource "aws_security_group" "sgnginx" {
  name        = "DevOps-NginX-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-NginX-Server-SG"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
    ]
    description = "Allow resonse from another server to NginX Server"
  }

  egress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
    ]
    description = "Allow SSH resonse from Bastion Server to another server"
  }

  egress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow resonse from NginX Server to another server"
  }
}

# Define the security group for Squid
resource "aws_security_group" "sgsquid" {
  name        = "DevOps_Squid_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-Squid-Server-SG"
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
    ]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
    ]
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_instance.bastion-server.private_ip}/32",
    ]
  }

  ingress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow resonse from another server to NginX Server"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH resonse from Bastion Server to another server"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH resonse from Bastion Server to another server"
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
      var.public_subnet_cidr,
      var.agent1_subnet_cidr,
      var.agent2_subnet_cidr,
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse from Server to another server"
  }
}

# Define the security group for Nexus
resource "aws_security_group" "sgnexus" {
  name        = "DevOps-Nexus-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-Nexus-Server-SG"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nginx.private_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-server.private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_instance.nginx.private_ip}/32",
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }
}

# Define the security group for Sonar
resource "aws_security_group" "sgsonar" {
  name        = "DevOps-Sonar-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-Sonar-Server-SG"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nginx.private_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-server.private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_instance.nginx.private_ip}/32",
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.private1_subnet_cidr,
      var.private2_subnet_cidr,
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }
}

# Define the security group for Jenkins
resource "aws_security_group" "sgjenkins" {
  name        = "DevOps-Jenkins-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-Jenkins-Server-SG"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nginx.private_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-server.private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_instance.nginx.private_ip}/32",
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }
}

# Define the security group for GitLab
resource "aws_security_group" "sggitlab" {
  name        = "DevOps-GitLab-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-GitLab-Server-SG"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nginx.private_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-server.private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_instance.nginx.private_ip}/32",
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.private1_subnet_cidr,
      var.private2_subnet_cidr,
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }
}

# Define the security group for Jira
resource "aws_security_group" "sgjira" {
  name        = "DevOps-Jira-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-Jira-Server-SG"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nginx.private_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-server.private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_instance.nginx.private_ip}/32",
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.private1_subnet_cidr,
      var.private2_subnet_cidr,
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }
}

# Define the security group for Confluence
resource "aws_security_group" "sgconfluence" {
  name        = "DevOps_Confluence_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-Confluence-Server-SG"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nginx.private_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-server.private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_instance.nginx.private_ip}/32",
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.private1_subnet_cidr,
      var.private2_subnet_cidr,
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }
}

# Define the security group for OpenLDAP
resource "aws_security_group" "sgopenldap" {
  name        = "DevOps_OpenLDAP_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-OpenLDAP-Server-SG"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nginx.private_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-server.private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_instance.nginx.private_ip}/32",
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse port from Nexus Server to another server"
  }
}

# Define the security group for Grafana
resource "aws_security_group" "sggrafana" {
  name        = "DevOps_Grafana_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-Grafana-Server-SG"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nginx.private_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-server.private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_instance.nginx.private_ip}/32",
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse port from Grafana Server to another server"
  }
}

# Define the security group for Zabbix
resource "aws_security_group" "sgzabbix" {
  name        = "DevOps_Zabbix_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-Zabbix-Server-SG"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.nginx.private_ip}/32"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion-server.private_ip}/32"]
  }

  egress {
    from_port = 32768
    to_port   = 65535
    protocol  = "tcp"
    cidr_blocks = [
      "${aws_instance.nginx.private_ip}/32",
      "${aws_instance.bastion-server.private_ip}/32",
    ]
    description = "Allow resonse port from Zabbix Server to another server"
  }
}

# Define the security group for private subnet
resource "aws_security_group" "sgdb" {
  name        = "DevOps-DB-SG"
  description = "Allow traffic from appplication subnet"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = "DevOps-DB-SG"
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

