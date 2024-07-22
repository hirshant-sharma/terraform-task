//Lunch Ec2 COnfig
resource "aws_instance" "test" {
  ami           = "ami-0edab43b6fa892279"
  instance_type = "t3.micro"
  tags = {
    name = "Test server"
  }
  key_name               = "test"
  availability_zone      = var.availability_zone
  subnet_id              = "subnet-07ebbe60"
  vpc_security_group_ids = [ aws_security_group.ssh-access.id ]

  user_data = <<EOF
#!/bin/bash
sudo apt update -y && sudo apt upgrade -y
sudo apt install nginx -y
sudo /etc/init.d/nginx enable
sudo /etc/init.d/nginx start
EOF
}

//Attach volume with EC2
resource "aws_ebs_volume" "ebs" {
  availability_zone = var.availability_zone
  size              = var.ebs_volume
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.ebs.id
  instance_id = aws_instance.test.id
}

//Create SG for EC2
resource "aws_security_group" "ssh-access" {
  name        = "ssh-access"
  description = "SG module Achintha Bandaranaike"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Create VPC
resource "aws_vpc" "default" {
  cidr_block = "10.1.0.0/16"    
  tags = {
    Name = "new-test"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet"
  }
}
