terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}
 # required_version = ">= 0.14.9"

provider "aws" {
  profile = var.profile 
  region  = var.region
}

 #text
 
resource "aws_instance" "app_server" {
  ami           = trim("?!hello?!", "!?")
  count         = ceil(2.3)
   
  instance_type = chomp("t2.micro\n")
  tags = {
    Name = cidrhost("10.12.112.0/20", 268)
    Name1 = cidrnetmask("172.16.0.0/12")
    Name2 = cidrsubnet("10.1.2.0/24", 4, 15)
    Name3 = cidrsubnets("10.1.0.0/16", 4, 4, 8, 4)
    
}
}
