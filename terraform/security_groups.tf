# Define the security group for public subnet
resource "aws_security_group" "sgbastion" {
  name        = var.project_name != "" ? "${var.project_name}-Bastion-SG" : "Bastion-SG"
  description = "Allow SSH access on Bastion Server"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Bastion-Server-SG" : "Bastion-Server-SG"
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
    description = "Allow SSH response from Another Server in VPC to Bastion server"
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
    description = "Allow SSH response from Bastion Server to another server"
  }
}

# Define the security group for NAT Instance
resource "aws_security_group" "sgnat" {
  name        = var.project_name != "" ? "${var.project_name}-NAT-SG" : "NAT-SG"
  description = "Allow incoming HTTP/HTTPS connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NAT-Instance-SG" : "NAT-Instance-SG"
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
    description = "Allow response port from NAT Server to another server"
  }
}

# Define the security group for NginX
resource "aws_security_group" "sgnginx" {
  name        = var.project_name != "" ? "${var.project_name}-NginX-SG" : "NginX-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-NginX-Server-SG" : "NginX-Server-SG"
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
    description = "Allow response from another server to NginX Server"
  }

  egress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = [
      var.application1_subnet_cidr,
      var.application2_subnet_cidr,
    ]
    description = "Allow SSH response from Bastion Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow response from NginX Server to another server"
  }
}

# Define the security group for Squid
resource "aws_security_group" "sgsquid" {
  name        = "DevOps_Squid_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Squid-Server-SG" : "Squid-Server-SG"
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
    description = "Allow response from another server to NginX Server"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH response from Bastion Server to another server"
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH response from Bastion Server to another server"
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
    description = "Allow response from Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Define the security group for Nexus
resource "aws_security_group" "sgnexus" {
  name        = var.project_name != "" ? "${var.project_name}-Nexus-SG" : "Nexus-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Nexus-Server-SG" : "Nexus-Server-SG"
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
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
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Define the security group for Sonar
resource "aws_security_group" "sgsonar" {
  name        = var.project_name != "" ? "${var.project_name}-Sonar-SG" : "Sonar-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Sonar-Server-SG" : "Sonar-Server-SG"
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
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
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.private1_subnet_cidr,
      var.private2_subnet_cidr,
    ]
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Define the security group for Jenkins
resource "aws_security_group" "sgjenkins" {
  name        = var.project_name != "" ? "${var.project_name}-Jenkins-SG" : "Jenkins-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jenkins-Server-SG" : "Jenkins-Server-SG"
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
    description = "Allow response port from Nexus Server to another server"
  }
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Define the security group for GitLab
resource "aws_security_group" "sggitlab" {
  name        = var.project_name != "" ? "${var.project_name}-GitLab-SG" : "GitLab-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-GitLab-Server-SG" : "GitLab-Server-SG"
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.private1_subnet_cidr,
      var.private2_subnet_cidr,
    ]
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Define the security group for Jira
resource "aws_security_group" "sgjira" {
  name        = var.project_name != "" ? "${var.project_name}-Jira-SG" : "Jira-SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Jira-Server-SG" : "Jira-Server-SG"
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
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.private1_subnet_cidr,
      var.private2_subnet_cidr,
    ]
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Define the security group for Confluence
resource "aws_security_group" "sgconfluence" {
  name        = "DevOps_Confluence_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Confluence-Server-SG" : "Confluence-Server-SG"
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
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = [
      var.private1_subnet_cidr,
      var.private2_subnet_cidr,
    ]
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Define the security group for OpenLDAP
resource "aws_security_group" "sgopenldap" {
  name        = "DevOps_OpenLDAP_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-OpenLDAP-Server-SG" : "OpenLDAP-Server-SG"
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
    description = "Allow response port from Nexus Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Define the security group for Grafana
resource "aws_security_group" "sggrafana" {
  name        = "DevOps_Grafana_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Grafana-Server-SG" : "Grafana-Server-SG"
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
    description = "Allow response port from Grafana Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

# Define the security group for Zabbix
resource "aws_security_group" "sgzabbix" {
  name        = "DevOps_Zabbix_SG"
  description = "Allow incoming HTTP connections & SSH access"
  vpc_id      = aws_vpc.devops.id

  tags = {
    Name = var.project_name != "" ? "${var.project_name}-Zabbix-Server-SG" : "Zabbix-Server-SG"
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
    description = "Allow response port from Zabbix Server to another server"
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Used to download packages"
  }
}

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

