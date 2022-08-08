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
    Name = base64decode("SGVsbG8gV29ybGQ=")
    Name1 = base64encode("Hello World")
    Name2 = csvdecode("a,b,c\n1,2,3\n4,5,6")
    Name3 = jsondecode("{\"hello\": \"world\"}")
    Name4 = jsonencode({"hello"="world"})
    Name5 =	textdecodebase64("SABlAGwAbABvACAAVwBvAHIAbABkAA==", "UTF-16LE")
    Name6 = textencodebase64("Hello World", "UTF-16LE")
    Name7 = urlencode("Hello World")
    Name8 = yamldecode("hello: world")
    Name9 = yamlencode({"a":"b", "c":"d"})
    
}
}
