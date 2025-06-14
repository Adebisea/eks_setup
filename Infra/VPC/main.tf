# create vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "app-vpc"
  }
}

#Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "app-igw"
  }
}


#Create Nat Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.pub3_subnet.id

  tags = {
    Name = "app_Nat"
  }
  depends_on = [aws_internet_gateway.gw]
}

#create elastic IP
resource "aws_eip" "lb" {
  domain   = "vpc"
}

