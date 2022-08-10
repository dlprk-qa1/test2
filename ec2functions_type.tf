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
    Name = tobool("true")
    Name1 = tolist([a, b, c])
    Name2 = toset(["c", "b", "b"])
    Name3 = tostring("hello")
    Name4 = tostring(null)
    Name5 = tonumber("1") 
    Name6 = tomap({"a" = 1, "b" = 2})  
}
}
