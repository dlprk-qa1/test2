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
    Name = alltrue([true, false])
    Name1 = anytrue(["true"]) 
    Name2 = chunklist(["a", "b", "c", "d", "e"], 2)
    Name3 = coalesce("a", "b")
    Name4 = coalescelist([], ["c", "d"])
    Name5 =	compact(["a", "", "b", "c"])
    Name6 = contains(["a", "b", "c"], "a")
    Name7 = concat(["a", ""], ["b", "c"])
    Name8 = distinct(["a", "b", "a", "c", "d", "b"])
    Name9 = element(["a", "b", "c"], 1)
    Name10 = index(["a", "b", "c"], "b")
    Name11 = keys({a=1, c=2, d=3})
    Name12 = length({"a" = "b"})
    Name13 = merge({a="b", c="d"}, {e="f", c="z"})
    Name14 = one(["hello"])
    Name15 = range(1, 4)
    Name16 = reverse([1, 2, 3])
    Name17 = setproduct(["a"], ["b"])
    Name18 = setsubtract(["a", "b", "c"], ["a", "c"])
    Name19 = setunion(["a", "b"], ["b", "c"], ["d"])
    Name20 = slice(["a", "b", "c", "d"], 1, 3)
    Name21 = sort(["e", "d", "a", "x"])
    Name22 = sum([10, 13, 6, 4.5])
    Name23 = transpose({"a" = ["1", "2"], "b" = ["2", "3"]})
    Name24 = flatten([["a", "b"], [], ["c"]])
    Name25 = values({a=3, c=2, d=1})
    Name26 = zipmap(["a", "b"], [1, 2])
    Name27 = setintersection(["a", "b"], ["b", "c"], ["b", "d"])
    Name28 = distinct(["a", "b", "a", "c", "d", "b"])
    Name29 = lookup({a="ay", b="bee"}, "a", "what?")
   
}
}
