#Create VPC only
resource "aws_vpc" "dev" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "dev"
  }
}

#Create Private subnet
resource "aws_subnet" "dev_private_sub" {
  cidr_block        = "10.1.1.0/24"
  vpc_id            = aws_vpc.dev.id
  availability_zone = "eu-east-1a"
  tags = {
    Name = "dev_private_sub"
  }
}
#Create Public subnet
resource "aws_subnet" "dev_public_sub" {
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-east-1a"
  vpc_id                  = aws_vpc.dev.id
  tags = {
    Name = "dev_public_sub"
  }
}

#Create IGW for public subnet
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev.id
  depends_on = [
    aws_vpc.dev,
    aws_subnet.dev_public_sub,
    aws_subnet.dev_private_sub
  ]
  tags = {
    Name = "dev-igw"
  }
}

#create route table for public subnet
resource "aws_route_table" "dev-public-crt" {
  vpc_id = aws_vpc.dev.id

  depends_on = [
    aws_vpc.dev,
    aws_internet_gateway.dev-igw
  ]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-igw.id
  }

  tags = {
    Name = "dev-public-crt"
  }
}

#assoceat route table to public subnet
resource "aws_route_table_association" "dev-crta-public-subnet-1" {
  subnet_id      = aws_subnet.dev_public_sub.id
  route_table_id = aws_route_table.dev-public-crt.id

  depends_on = [
    aws_vpc.dev,
    aws_subnet.dev_public_sub,
    aws_subnet.dev_private_sub
  ]
}

# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  depends_on = [
    aws_route_table_association.dev-crta-public-subnet-1
  ]
  vpc = true
}

# Creating a NAT Gateway!
resource "aws_nat_gateway" "NAT_GATEWAY" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]

  # Allocating the Elastic IP to the NAT Gateway!
  allocation_id = aws_eip.Nat-Gateway-EIP.id

  # Associating it in the Public Subnet!
  subnet_id = aws_subnet.dev_public_sub.id
  tags = {
    Name = "Nat-Gateway_Project"
  }
}

# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT" {
  depends_on = [
    aws_nat_gateway.NAT_GATEWAY
  ]

  vpc_id = aws_vpc.dev.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY.id
  }

  tags = {
    Name = "Route Table for NAT Gateway"
  }

}

# Creating an Route Table Association of the NAT Gateway route 
# table with the Private Subnet!
resource "aws_route_table_association" "Nat-Gateway-RT-Association" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]

  #  Private Subnet ID for adding this route table to the DHCP server of Private subnet!
  subnet_id = aws_subnet.dev_private_sub.id

  # Route Table ID
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}
