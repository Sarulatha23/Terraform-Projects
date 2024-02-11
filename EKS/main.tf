#create VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.my_vpc

  azs                     = data.aws_availability_zones.AZ.names
  public_subnets          = var.pub-subnet
  map_public_ip_on_launch = true
  enable_dns_hostnames    = true

  tags = {
    Name        = "MY-VPC"
    Terraform   = "true"
    Environment = "dev"
  }
  public_subnet_tags = {
    Name = "VPC-subnet"
  }
}

#Create Security group

module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "VPC-Security_group"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0"
    }

  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  tags = {
    Name = "Security-groups"
  }
}
# Create EC2 instance

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Jenkins-server-instance"

  instance_type               = var.instance_type
  key_name                    = "session1"
  monitoring                  = true
  vpc_security_group_ids      = [module.vote_service_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  availability_zone           = data.aws_availability_zones.AZ.names[0]
  user_data                   = file("jenkins-install.sh")

  tags = {
    Name        = "ec21"
    Terraform   = "true"
    Environment = "dev"
  }
}
