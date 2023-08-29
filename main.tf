terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      
    }
  }

  
}

provider "aws" {
  region  = "ap-south-1"
}
# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" # Adjusting the CIDR block as needed

  tags = {
    Name = "MyVPC"
  }
}

# Create a public subnet in the VPC
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24" # Adjusting the CIDR block as needed
  availability_zone       = "ap-south-1a" # Changing the availability zone as needed

  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet"
  }
}

# Create a private subnet in the VPC
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24" # Adjusting the CIDR block as needed
  availability_zone       = "ap-south-1b" # Changing the availability zone as needed

  tags = {
    Name = "PrivateSubnet"
  }
}

# Create a security group for the EC2 instance
resource "aws_security_group" "instance_security_group" {
  name        = "instance-sg"
  description = "Security group for EC2 instance"

  # Inbound rule for SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule for all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.my_vpc.id
}

# Create an EC2 instance in the public subnet
resource "aws_instance" "ec2_instance" {
  ami           = "ami-06f621d90fa29f6d0" #  desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id

  # Attach the security group created above to the instance
  vpc_security_group_ids = [aws_security_group.instance_security_group.id]

  # Specify the root volume properties
  root_block_device {
    volume_size = 8
    volume_type = "gp2"
    encrypted   = false
  }

  # Add a tag to the EC2 instance
  tags = {
    Name    = "MyEC2Instance"
    purpose = "Assignment"
  }
}



