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


# List availability zones in region
data "aws_availability_zones" "az_list" {
  state = "available"
}

# pub1 subnet
resource "aws_subnet" "pub1_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub1_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az_list.names[0]

  tags   = {
    Name = "pub1_subnet"
  }
}

# pub2 subnet
resource "aws_subnet" "pub2_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub2_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az_list.names[1]

  tags   = {
    Name = "pub2_subnet"
  }
}

# pub3 subnet
resource "aws_subnet" "pub3_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub3_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az_list.names[2]

  tags   = {
    Name = "nat_subnet"
  }
}

# prv1 subnet
resource "aws_subnet" "prv1_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.prv1_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az_list.names[0]

  tags   = {
    Name = "prv1_subnet"
  }
}

# prv2 subnet
resource "aws_subnet" "prv2_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.prv2_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az_list.names[1]

  tags   = {
    Name = "prv2_subnet"
  }
}

# prv3 subnet
resource "aws_subnet" "prv3_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.prv3_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.az_list.names[1]

  tags   = {
    Name = "prv3_subnet"
  }
}

