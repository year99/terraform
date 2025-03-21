# Add provider
provider "aws" {
  region = "ap-northeast-2"
}

# VPC
resource "aws_vpc" "tf-vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "tf-vpc"
  }
}

# Subnet
# Refer http://blog.itsjustcode.net/blog/2017/11/18/terraform-cidrsubnet-deconstructed/
resource "aws_subnet" "tf-subnet" {
  vpc_id                  = aws_vpc.tf-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.tf-vpc.cidr_block, 3, 1)
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
}

# Security Group

resource "aws_security_group" "tf-ingress-all" {
  name   = "tf-ingress-allow-all"
  vpc_id = aws_vpc.tf-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {// Allow all traffic from internet
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  // Terraform requires egress to be defined as it is disabled by default..
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


# EC2 Instance for testing
// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "tf-ec2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.ami_key_pair
  subnet_id              = aws_subnet.tf-subnet.id
  vpc_security_group_ids = [aws_security_group.tf-ingress-all.id]
  tags = {
    Name = "tf-ec2"
  }
}
//
# To access the instance, we would need an elastic IP
resource "aws_eip" "tf-eip" {// Elastic IP
  instance = aws_instance.tf-ec2.id
#  vpc      = true
}

# Route traffic from internet to the vpc
resource "aws_internet_gateway" "tf-igw" {
  vpc_id = aws_vpc.tf-vpc.id
  tags = {
    Name = "tf-igw"
  }
}

# Setting up route table
resource "aws_route_table" "tf-rt" {
  vpc_id = aws_vpc.tf-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-igw.id
  }// Route traffic from internet to the vpc

  tags = {// Tagging the route table
    Name = "tf-rt"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "tf-rt-assoc" {// Associate route table with subnet
  subnet_id      = aws_subnet.tf-subnet.id
  route_table_id = aws_route_table.tf-rt.id
}

# Add a SNS topic
resource "aws_sns_topic" "tf-sns-topic" {// Simple Notification Service
  name = "tf-sns-topic"
}

