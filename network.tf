# 1 - VPC   
resource "aws_vpc" "vpc_a" {
  cidr_block = "10.0.0.0/16"

  tags = {
    name = "Point"
  }
}

# 2 - Internet Gateway
resource "aws_internet_gateway" "G_Point" {
  vpc_id = aws_vpc.vpc_a.id

  tags = {
    Name = "G_Point"
  }
}

# 3 - Route Table
resource "aws_route_table" "RT_Point" {
  vpc_id = aws_vpc.vpc_a.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.G_Point.id
  }

  tags = {
    Name = "RT_Point"
  }
}

# 4 - Subnet
resource "aws_subnet" "SN_Point" {
  vpc_id            = aws_vpc.vpc_a.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  depends_on        = [aws_internet_gateway.G_Point]

  tags = {
    Name = "SN_Point"
  }
}

# 5 - Associate Subnet with Route Table
resource "aws_route_table_association" "RT_to_Subnet" {
  subnet_id      = aws_subnet.SN_Point.id
  route_table_id = aws_route_table.RT_Point.id
}

# 6 - Security Group to allow ports: 22, 80, 443, 3306
resource "aws_security_group" "SG_IpamApp" {
  name        = "SG_IpamApp"
  description = "Allow HTTPS, HTTP, SSH, SGBD and ICMP "
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["xxx.xxx.xxx.xxx/27", "xxx.xxx.xxx.xxx/28", "10.0.1.0/24"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["xxx.xxx.xxx.xxx/27", "xxx.xxx.xxx.xxx/28", "10.0.1.0/24"]
  }

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["xxx.xxx.xxx.xxx/27", "xxx.xxx.xxx.xxx/28", "10.0.1.0/24"]
  }

  ingress {
    description = "MariaDB from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["xxx.xxx.xxx.xxx/27", "xxx.xxx.xxx.xxx/28", "10.0.1.0/24"]
  }

  ingress {
    description = "ICMP from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_IpamApp"
  }
}

# 7 - Security Group to allow ports: 22, 3306
resource "aws_security_group" "SG_IpamDB" {
  name        = "SG_IpamDB"
  description = "Allow SSH, SGBD and ICMP"
  vpc_id      = aws_vpc.vpc_a.id

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["xxx.xxx.xxx.xxx/27", "xxx.xxx.xxx.xxx/28", "10.0.1.0/24"]
  }

  ingress {
    description = "MariaDB from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["xxx.xxx.xxx.xxx/27", "xxx.xxx.xxx.xxx/28", "10.0.1.0/24"]
  }

  ingress {
    description = "ICMP from VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG_IpamDB"
  }
}

# 8 - Elastic IP for IpamApp
resource "aws_eip" "EIP_A_IpamApp" {
  depends_on = [aws_internet_gateway.G_Point]

  tags = {
    Name = "EIP_A_IpamApp"
  }
}

# 9 - Elastic IP for IpamDB
resource "aws_eip" "EIP_A_IpamDB" {
  depends_on = [aws_internet_gateway.G_Point]

  tags = {
    Name = "EIP_A_IpamDB"
  }
}

# 10 - Associate Elastic IP to EC2 Instance IpamAPP
resource "aws_eip_association" "EIP_Association_IpamApp" {
  instance_id   = aws_instance.serverIpamApp.id
  allocation_id = aws_eip.EIP_A_IpamApp.id

  depends_on = [
    aws_instance.serverIpamApp,
    aws_eip.EIP_A_IpamApp
  ]
}

# 11 - Associate Elastic IP to EC2 Instance IpamDB
resource "aws_eip_association" "EIP_Association_IpamDB" {
  instance_id   = aws_instance.serverIpamDB.id
  allocation_id = aws_eip.EIP_A_IpamDB.id

  depends_on = [
    aws_instance.serverIpamDB,
    aws_eip.EIP_A_IpamDB
  ]
}

# 12 - SSH Key for IpamAPP
resource "aws_key_pair" "key_ipam" {
  key_name   = "key_ipam"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwhCzHpoVP+nCMWIlMEne/dJndZlv7vMNJqMoXsPGZgf+o7WbK0YvBo4SJ5m26EcVsLzXv7hTAAdKZV3sBdPHJNbvQ7dIqt2v18STiSYfwd35eunsAW97nAYQ/CI56q8bFCWaOSq2wy5MwwhrFrGTtMJHFeNyoI5rNy7EyGmX+HPxa/vXJHsthD5RJPgHlGJucSLJrzXGh6YBOU9CIvXT8d8P8mUT4/D0zBYdoV2dIkqe9IghhfYGdfjkfjz66tiR8/ahopi6wf+yy3wGPVgdsJaawMo78k+biWd+3aOTrpP9MlqbQZIjhmgnSd/jZOeteHClUwlBmjV key_ipam"
}

# 13 - SSH Key for IpamDB
resource "aws_key_pair" "key_ipamdb" {
  key_name   = "key_ipamdb"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5OKxzhbNYxZXceiPonJ3QRVdMc3ab1D+UfyuTsHru14uiM58ZeiOW1Hl8doqHZG6PmwNaoKmSBWhnfTAp44Fxl960rfqRrmpbBB05zQbIrFSKbUZ2ESkYOFZRFga2Z+/u9kf6bpsxKrYf6QU5pAPmAOOscSZIMpyhpkZN82bd+QrQ7Rn1hcKprV8aBqWlBUHe1KXpybl8wHWtbUaGlXj6+iXtDvxo1VSskbYURByFxw1S+giAEQFdVCI/XzL2LTMEmVpInuYgn167Jc+Blx42jEPWSJQxwg+AKdG7rVq2/GcwF1RhRd0o4QCzyvndbCTSsOKa9SHitE key_ipamdb"
}