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
    Name = format("Hello, %s!", "Ander")
    Name1 = formatlist("%s, %s!", "Salutations", ["Valentina", "Ander", "Olivia", "Sam"])
    Name2 = regex("(\\d\\d\\d\\d)-(\\d\\d)-(\\d\\d)", "2019-02-01")
    Name3 = regexall("[a-z]+", "1234abcd5678efgh9")
    Name4 = regex("^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?", "https://terraform.io/docs/")
    Name5 = strrev("a b")
    Name6 = substr("hello world", -5, -1)
    Name7 = chomp("hello\n")
    Name8 = join(", ", ["foo", "bar", "baz"])
    Name9 = lower("АЛЛО!")
    Name10 = replace("1 + 2 + 3", "+", "-")
    Name11 = split(",", "foo,bar,baz")
    Name12 = substr("🤔🤷", 0, 1)
    Name13 = title("hello world")
    Name14 = trim("?!hello?!", "!?")
    Name15 =trimprefix("helloworld", "hello")
    Name16 = trimsuffix("helloworld", "world")
    Name17 = upper("hello")
    
}
}
