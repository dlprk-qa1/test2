terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
      #version = "3.27"
      #version = "4.0.0"
    }


        pgp = {
      source = "ekristen/pgp"
    }
  
      random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }

  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"

}

data "aws_region" "current" {}


resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}


resource "aws_ecr_repository" "card-processing-container-repo" {
  name                 = "ecrrepo-cardprocessing-dev-${data.aws_region.current.name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

##### IAM role to assign to EC2 instance(s), to demonstrate CIEM capabilities:

resource "aws_iam_role" "machine-storage-access" {
  name = "machine-storage-access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      env = "dev"
  }
}


resource "aws_iam_instance_profile" "storage-access-profile" {
  name = "storage-access-profile"
  role = "${aws_iam_role.machine-storage-access.name}"
}


resource "aws_iam_role_policy" "storage-access-policy" {
  name = "storage-access-policy"
  role = "${aws_iam_role.machine-storage-access.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*",
        "ec2:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_instance" "cardprocessing-frontend" {
  ami = "ami-0ca285d4c2cda3300"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.storage-access-profile.name}"

    tags = {
    Name = "ec2-cardprocessingfrontend-dev-${data.aws_region.current.name}-1"
  }
}


resource "aws_instance" "cardprocessing-nodejs-frontend" {
  ami = "ami-0c574ce8ee8127ce0"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.storage-access-profile.name}"

    tags = {
    Name = "ec2-cardprocessingnodejsfrontend-dev-${data.aws_region.current.name}-1"
  }
}


resource "aws_instance" "cardprocessing-nodejs-frontend-2" {
  ami = "ami-0c574ce8ee8127ce0"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.storage-access-profile.name}"

    tags = {
    Name = "ec2-cardprocessingnodejsfrontend-dev-${data.aws_region.current.name}-2"
  }
}

##### Elastic IP for an instance: 

resource "aws_eip" "elastic-ip" {
  instance = aws_instance.cardprocessing-nodejs-frontend.id
  vpc      = true
}


resource "aws_iam_user" "developer-admin" {
  name = "dev-admin"
 # path = "/system/"

  tags = {
    env = "dev"
  }
}

resource "aws_iam_access_key" "developer-key" {
  user = aws_iam_user.developer-admin.name
}

resource "aws_iam_user_policy" "developer_policy" {
  name = "developer-policy"
  user = aws_iam_user.developer-admin.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}



locals {
  users = {
    "john.doe" = {
      name  = "John Smith"
      email = "john.smith@safemarch.com"
    },
    "anna.klein" = {
        name = "Anna Klein"
        email = "anna.klein@safemarch.com"
    } 
  }
}


resource "aws_iam_user_policy" "user_policy" {
  for_each = local.users

 name = "user-policy"
  user = each.key

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "user" {
  for_each = local.users

  name          = each.key
  force_destroy = false
}

resource "aws_iam_access_key" "user_access_key" {
  for_each = local.users
  
  user       = each.key
  depends_on = [aws_iam_user.user]
}

resource "pgp_key" "user_login_key" {
  for_each = local.users

  name    = each.value.name
  email   = each.value.email
  comment = "PGP Key for ${each.value.name}"
}

resource "aws_iam_user_login_profile" "user_login" {
  for_each = local.users

  user                    = each.key
  pgp_key                 = pgp_key.user_login_key[each.key].public_key_base64
  password_reset_required = true

  depends_on = [aws_iam_user.user, pgp_key.user_login_key]
}

data "pgp_decrypt" "user_password_decrypt" {
  for_each = local.users

  ciphertext          = aws_iam_user_login_profile.user_login[each.key].encrypted_password
  ciphertext_encoding = "base64"
  private_key         = pgp_key.user_login_key[each.key].private_key
}

output "credentials" {
  value = {
    for k, v in local.users : k => {
      "key"      = aws_iam_access_key.user_access_key[k].id
      "secret"   = aws_iam_access_key.user_access_key[k].secret
      "password" = data.pgp_decrypt.user_password_decrypt[k].plaintext
    }
  }
  sensitive = true
}


##### Administrator access - AWS managed policy  - resources:

resource "aws_iam_group" "dev-admins" {
  name = "dev-admins"
}


data "aws_iam_policy" "AdministratorAccess" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_group_policy_attachment" "dev-admins-policy-attachment" {
  group      = aws_iam_group.dev-admins.name
  policy_arn = "${data.aws_iam_policy.AdministratorAccess.arn}"
}




resource "aws_iam_group_membership" "admins" {
  name = "dev-admins-group-membership"


    for_each = local.users
    users       = [each.key]


  

  group = aws_iam_group.dev-admins.name
}



##### EC2 instance behing load balancer (ELB):




module "elb_example_complete" {
  source  = "terraform-aws-modules/elb/aws//examples/complete"
  version = "3.0.1"
}


data "aws_instance" "frontend-1" {


  filter {
    name   = "tag:Name"
    values = ["ec2-cardprocessingfrontend-dev-us-west-2-1"]
  }
}


module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "~> 2.0"

  name = "elb-cardprocessing-dev-${data.aws_region.current.name}"

  subnets         = [aws_subnet.eks-subnet-2.id, aws_subnet.eks-subnet-2.id]
  security_groups = [aws_security_group.allow_tls_lb.id]
  internal        = false

  listener = [
    {
      instance_port     = 80
      instance_protocol = "HTTP"
      lb_port           = 80
      lb_protocol       = "HTTP"
    },
    {
      instance_port     = 8080
      instance_protocol = "http"
      lb_port           = 8080
      lb_protocol       = "http"
      #ssl_certificate_id = "arn:aws:acm:eu-west-1:235367859451:certificate/6c270328-2cd5-4b2d-8dfd-ae8d0004ad31"
    },
  ]

  health_check = {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  access_logs = {
    bucket = "frontend-lb-access-logs-bucket-development"
  }

  // ELB attachments
  number_of_instances = 2
  instances           = ["i-0e943dfa0164eaaa4"]

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

##### Security group for the load balancer: 

resource "aws_security_group" "allow_tls_lb" {
  name        = "allow_tls_lb"
  description = "Allow TLS inbound traffic to load balancer"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_default_vpc.default.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

data "aws_elb_service_account" "main" {}



##### S3 bucket for the load balancer logs: 
resource "aws_s3_bucket" "lb-logs-bucket" {
  bucket = "frontend-lb-access-logs-bucket-development"

  tags = {
    Name        = "frontend-lb-access-logs-bucket-development"
    Environment = "Dev"
  }

   policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::frontend-lb-access-logs-bucket-development/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

/*
//resource "aws_s3_bucket_acl" "lb-logs-bucket-acl" {
//  bucket = aws_s3_bucket.lb-logs-bucket.id
//  acl    = "private"
}
*/




##### EC2 instance with GPU to trigger crypto mining threat: 


resource "aws_instance" "crypto-miner-demo1" {
  ami           = "ami-0ca285d4c2cda3300"
  instance_type = "p2.xlarge"
  security_groups = ["allow_any_port"]

  tags = {
    Name = "CryptoMiner"
  }
}



##### EKS Cluster:

resource "aws_eks_cluster" "dev-eks" {
  name     = "eks-cardprocessing-dev-${data.aws_region.current.name}"
  role_arn = aws_iam_role.dev-eks-iam-role.arn

  vpc_config {
    subnet_ids = [aws_subnet.eks-subnet-1.id, aws_subnet.eks-subnet-2.id]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.Policy-Attachement-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.Policy-Attachement-AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.dev-eks.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.dev-eks.certificate_authority[0].data
}

##### EKS IAM Role:

resource "aws_iam_role" "dev-eks-iam-role" {
  name = "eks-cluster-dev"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "Policy-Attachement-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.dev-eks-iam-role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "Policy-Attachement-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.dev-eks-iam-role.name
}



##### Subnets for EKS Cluster:

resource "aws_subnet" "eks-subnet-1" {
  vpc_id     = aws_default_vpc.default.id
  cidr_block = "172.31.100.0/24"

  tags = {
    Name = "eks-subnet-1"
  }
}

resource "aws_subnet" "eks-subnet-2" {
  vpc_id     = aws_default_vpc.default.id
  cidr_block = "172.31.250.0/24"

  tags = {
    Name = "eks-subnet-2"
  }
}


##### Unecnrypted EBS volume:

resource "aws_ebs_volume" "cradnumbers" {
  availability_zone = "us-west-2a"
  size              = 5

  tags = {
    Name = "card-processing-card-numbers"
  }
}


##### Security group allowing traffic from any on any port:

resource "aws_security_group" "allow_any_port" {
  name        = "allow_any_port"
  description = "Allow any traffic from anywhere"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description      = "Any Traffic"
    from_port        = 1
    to_port          = 65000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_any"
  }
}

##### AWS Placement group:

resource "aws_placement_group" "cardprocessing-cluster" {
  name     = "cardprocessing-dev-${data.aws_region.current.name}-placementgroup-cluster"
  strategy = "spread"
}


##### Launch configuration:

data "aws_ami" "ubuntu" {

    most_recent = true

    filter {  
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"]
}

resource "aws_launch_configuration" "as_conf" {
  name          = "cardprocessing-dev-frontend-config"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}





