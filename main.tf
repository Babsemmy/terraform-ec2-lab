provider "aws" {
  region = "ap-northeast-3"
}

# --- Subnet ---
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "vpc-00ffe463659a905fd"  
  cidr_block              = "10.0.16.0/24"
  availability_zone       = "ap-northeast-3a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Emmanuel_Subnet"
  }
}

# --- Route Table Association ---
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = "rtb-0d9918b937b3b41e9"   
}

# --- Security Group ---
resource "aws_security_group" "web_sg" {
  name        = "emmanuel-web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = "vpc-00ffe463659a905fd"   

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

# --- EC2 Instance ---
resource "aws_instance" "ubuntu_server" {
  ami           = "ami-0ba0e5fd5d40b482c" # Ubuntu 22.04 LTS in ap-northeast-3
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              echo "Hello from Terraform CI/CD App!" > /var/www/html/index.html
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "UbuntuAppServer"
  }
}
