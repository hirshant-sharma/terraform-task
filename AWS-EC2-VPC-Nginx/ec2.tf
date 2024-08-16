resource "aws_security_group" "ssh-allowed" {
  vpc_id = aws_vpc.dev.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssh-allowed"
  }
}


resource "aws_instance" "nginxserver" {
  ami                         = var.AMI
  key_name                    = "key"
  instance_type               = var.size
  vpc_security_group_ids      = [aws_security_group.ssh-allowed.id]
  subnet_id                   = aws_subnet.dev_public_sub.id
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              sudo apt install nginx -y
              sudo systemctl status nginx
              EOF


  tags = {
    Name = "Nginx server"
  }
}