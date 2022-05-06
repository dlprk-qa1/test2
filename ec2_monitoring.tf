provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

 #text

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"
  ingress_cidr_blocks = ["0.0.0.0/16"]
  monitoring = false
  tags = {
    Name = "ExampleAppServerInstance"
  }
}
