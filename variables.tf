# 1 - Define Region
variable "region" {
  description = "Region the instance will be deployed"
  default     = "us-east-1"
}

# 2 - Variables for IpamAPP
variable "name" {
  description = "Name of the server"
  default     = "server_Ipam"
}

variable "env" {
  description = "Environment of the machine"
  default     = "dev"
}

variable "ami" {
  description = "AMI used"
  default     = "ami-0e001c9271cf7f3b9"
}

variable "instance_type" {
  description = "Defines the hardware configuration of the machine"
  default     = "t2.micro"
}

variable "repo" {
  description = "Repository of the application in GitHub"
  default     = "https://github.com/DiegoRodrig0/Infraestrutura-como-Codigo"
}

# 3 - Variables for IpamDB
variable "name_db" {
  description = "Name of the server"
  default     = "server_Ipam_db"
}

variable "env_db" {
  description = "Environment of the machine"
  default     = "dev"
}

variable "ami_db" {
  description = "AMI used"
  default     = "ami-0e001c9271cf7f3b9"
}

variable "instance_type_db" {
  description = "Defines the hardware configuration of the machine"
  default     = "t2.micro"
}

variable "repo_db" {
  description = "Repository of the application in GitHub"
  default     = "https://github.com/DiegoRodrig0/Infraestrutura-como-Codigo"
}