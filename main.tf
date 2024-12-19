provider "aws" {
  region = var.region
}

resource "aws_instance" "serverIpamApp" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.SN_Point.id
  vpc_security_group_ids = [aws_security_group.SG_IpamApp.id]
  key_name               = aws_key_pair.key_ipam.key_name

  tags = {
    Name        = var.name
    Environment = var.env
    Provisioner = "Terraform"
    Repo        = var.repo
  }
}

resource "aws_instance" "serverIpamDB" {
  ami                    = var.ami_db
  instance_type          = var.instance_type_db
  subnet_id              = aws_subnet.SN_Point.id
  vpc_security_group_ids = [aws_security_group.SG_IpamDB.id]
  key_name               = aws_key_pair.key_ipamdb.key_name

  tags = {
    Name        = var.name_db
    Environment = var.env_db
    Provisioner = "Terraform"
    Repo        = var.repo_db
  }
}