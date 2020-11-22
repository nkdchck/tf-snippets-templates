# provider "aws" {
#   region = "us-east-1"
#   access_key = "<Access Key>"
#   secret_key = "<Secret Key>"
# }

# resource "aws_subnet" "subnet-1" {
#   vpc_id     = aws_vpc.productionVPC.id
#   cidr_block = "10.0.1.0/24"

#   tags = {
#     Name = "subnet-1"
#   }
# }

# resource "aws_subnet" "subnet-2" {
#   vpc_id     = aws_vpc.devVPC.id
#   cidr_block = "10.1.1.0/24"

#   tags = {
#     Name = "subnet-2"
#   }
# }

# resource "aws_vpc" "productionVPC" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "productionVPC"
#   }
# }

# resource "aws_vpc" "devVPC" {
#   cidr_block = "10.1.0.0/16"
#   tags = {
#     Name = "devVPC"
#   }
# }

# resource "aws_instance" "ubuntuServer" {
#   ami           = "ami-0885b1f6bd170450c"
#   instance_type = "t2.micro"
#   tags = {
#     Name = "ubuntuServer"
#   }
# }