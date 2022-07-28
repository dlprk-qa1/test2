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
    Name = base64sha256("hello world")
    Name1 = base64sha512("hello world") 
    Name2 = bcrypt("hello world")
    Name3 = md5("hello world")
    Name4 = rsadecrypt(filebase64("${path.module}/ciphertext"), file("privatekey.pem"))
    Name5 =	sha1("hello world")
    Name6 = sha256("hello world")
    Name7 = sha512("hello world")
    Name8 = uuid()
    Name9 = uuidv5("dns", "www.terraform.io")
    
}
}
