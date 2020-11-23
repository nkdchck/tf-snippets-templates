# Web Server deployment using Terraform
# Simple deployment to default vpc. Checkout sample_deployment for full custom vpc setup snippet.

provider "aws" {}


resource "aws_vpc" "web_server_vpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "web_server_vpc"
  }
}

resource "aws_subnet" "web_server_subnet" {
  vpc_id     = aws_vpc.web_server_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "web_server_subnet"
  }
}

resource "aws_security_group" "sg" {
  name        = "web_server_sg"
  description = "Web Server security group"
  vpc_id      = aws_vpc.web_server_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg"
  }
}

resource "aws_instance" "web_server" {
    ami = "ami-0885b1f6bd170450c"
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.sg.id]
    subnet_id = aws_subnet.web_server_subnet.id
    tags = {
        Name = "web_server"
    }
    user_data = <<EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo your web server > /var/www/html/index.html'
                EOF
}


