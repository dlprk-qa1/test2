resource "aws_ebs_volume" "example1" {
  availability_zone = "us-west-2a"
  size              = 40
  encrypted         = false
  tags = {
    Name = "HelloWorld"
  }
}
