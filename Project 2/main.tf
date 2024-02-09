terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#VPC
resource "aws_vpc" "my-vpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC1"
  }
}

#Subnet

resource "aws_subnet" "pubsub" {
  vpc_id            = aws_vpc.my-vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-la"
  tags = {
    Name = "Public-subnet"
  }
}

resource "aws_subnet" "prisub" {
  vpc_id            = aws_vpc.my-vpc1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-la"
  tags = {
    Name = "private-subnet"
  }
}

#Internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc1.id

  tags = {
    Name = "internet gateway"
  }
}

#public route table & associate to subnet
resource "aws_route_table" "pubRT" {
  vpc_id = aws_vpc.my-vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "publicroutetable"
  }
}

resource "aws_route_table_association" "asspublic" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubRT.id
}

# EIP and nAT gateway and private subnet and associate it subnet 

resource "aws_eip" "my_eip" {

  domain = "vpc"
}

resource "aws_nat_gateway" "priv-NAT-GATEWAY" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.pubsub.id

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "priRT" {
  vpc_id = aws_vpc.my-vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.priv-NAT-GATEWAY.id
  }

  tags = {
    Name = "privateroutetable"
  }
}

resource "aws_route_table_association" "asspublic-1" {
  subnet_id      = aws_subnet.prisub.id
  route_table_id = aws_route_table.priRT.id
}

#SG
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my-vpc1.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "ssh"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

}

resource "aws_security_group" "private" {
  name        = "private_ip"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my-vpc1.id

  tags = {
    Name = "private_ip"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4-pri" {
  security_group_id = aws_security_group.private.id
  cidr_ipv4         = "10.0.1.0/24"
  from_port         = 0
  ip_protocol       = "tcp"
  to_port           = 65535
}

#EC2 intance


resource "aws_instance" "Intance-1-pub" {
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t3.micro"
  key_name                    = "session1"
  vpc_security_group_ids      = [aws_security_group.allow_tls.id]
  subnet_id                   = aws_subnet.pubsub.id
  associate_public_ip_address = true

  tags = {
    Name = "HelloWorld"
  }
}

resource "aws_instance" "Intance-2-pri" {
  ami                         = "ami-0c7217cdde317cfec"
  instance_type               = "t3.micro"
  key_name                    = "session1"
  vpc_security_group_ids      = [aws_vpc_security_group_ingress_rule.allow_tls_ipv4.id]
  subnet_id                   = aws_subnet.pubsub.id
  associate_public_ip_address = true

  tags = {
    Name = "HelloWorld"
  }
}




