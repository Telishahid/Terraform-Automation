provider "aws" {
  region = "ap-south-1"
}

# 1. VPC
resource "aws_vpc" "main" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# 2. Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "172.16.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# 4. Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-rt"
  }
}

# 5. Route to Internet
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# 6. Route Table Association
resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# 7. Security Group
resource "aws_security_group" "sg" {
  name   = "jenkins-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sg"
  }
}

# 8. EC2 Instance
resource "aws_instance" "ec2" {
  ami                    = "ami-0f58b397bc5c1f2e8" # Amazon Linux (update if needed)
  instance_type          = "t2.micro"
  key_name               = "your-key-name"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "jenkins-server"
  }
}

# 9. Elastic IP
resource "aws_eip" "eip" {
  instance = aws_instance.ec2.id
  vpc      = true

  tags = {
    Name = "ec2-eip"
  }
}
