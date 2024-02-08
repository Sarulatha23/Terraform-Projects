#VPC

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "myJenkins-vpc"
  cidr = var.aws_cidr

  azs            = data.aws_availability_zones.az_zones.names
  public_subnets = var.public_subnet

  enable_dns_hostnames = true

  tags = {
    name        = "jenkins_VPC"
    Terraform   = "true"
    Environment = "dev"
  }
  public_subnet_tags = {
    Name = "Jenkins-subnet"
  }
}

#SG

module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-security-group"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "http"
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
    name = "Jenkins-sg"
  }
}

#EC2

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "my-ec2-instance"

  instance_type          = var.intance_type
  key_name               = "session1"
  monitoring             = true
  vpc_security_group_ids = [module.vote_service_sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]

  associate_public_ip_address = true
  user_data = file("jenkins_install.sh")
  availability_zone = data.aws_availability_zones.az_zones.names[0]
  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

