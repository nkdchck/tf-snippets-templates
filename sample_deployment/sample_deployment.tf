provider "aws" {}


variable "subnet_prefix" {
  description = "cidr blocks and tags for the subnets"
  # default = ""
  # type = String
}

#<----------------- List of steps ------------------>
# 1. Create vpc
# 2. Create Internet Gateway
# 3. Create Custom Route Table
# 4. Create a Subnet
# 5. Associate created subnet with Route Table
# 6. Create Security Group to allow port 22, 80, 443
# 7. Create a network interface with an ip in the subnet that was created in step 4
# 8. Assign an elastic IP to the network interface created in step 7
# 9. Create Ubuntu server and install/enable apache2

# 1. Create vpc

resource "aws_vpc" "prodVPC" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "prodVPC"
  }
}

# 2. Create Internet Gateway

resource "aws_internet_gateway" "prodVPC-Gateway" {
  vpc_id = aws_vpc.prodVPC.id

  tags = {
    Name = "prodVPC-Gateway"
  }
}

# 3. Create Custom Route Table

resource "aws_route_table" "prodVPC-RouteTable" {
  vpc_id = aws_vpc.prodVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prodVPC-Gateway.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.prodVPC-Gateway.id
  }

  tags = {
    Name = "prodVPC-RouteTable"
  }
}

# 4. Create a Subnet

resource "aws_subnet" "prodVPC-Subnet-1" {
  vpc_id     = aws_vpc.prodVPC.id
  cidr_block = var.subnet_prefix[0].cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = var.subnet_prefix[0].name
  }
}

# 5. Associate created subnet with Route Table

resource "aws_route_table_association" "prodVPC-Subnet-1-to-prodVPC-RouteTable" {
  subnet_id      = aws_subnet.prodVPC-Subnet-1.id
  route_table_id = aws_route_table.prodVPC-RouteTable.id
}

# 6. Create Security Group to allow port 22, 80, 443

resource "aws_security_group" "allow_HTTPS_HTTP_SSH" {
  name        = "allow_web_traffic"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.prodVPC.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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
    Name = "allow_HTTPS_HTTP_SSH"
  }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4

resource "aws_network_interface" "nic-for-prodVPC-Subnet-1" {
  subnet_id       = aws_subnet.prodVPC-Subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_HTTPS_HTTP_SSH.id]
}

# 8. Assign an elastic IP to the network interface created in step 7

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.nic-for-prodVPC-Subnet-1.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.prodVPC-Gateway]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

# 9. Create Ubuntu server and install/enable apache2

resource "aws_instance" "apache-web-server-instance" {
    ami = "ami-00ddb0e5626798373"
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "awskeypair"

    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.nic-for-prodVPC-Subnet-1.id
    }

    user_data = file("./user_data.sh")

    tags = {
        Name = "apache-web-server-instance"
    }
}

output "server_private_ip" {
  value = aws_instance.apache-web-server-instance.private_ip
}
output "server_arn" {
  value = aws_instance.apache-web-server-instance.arn
}
