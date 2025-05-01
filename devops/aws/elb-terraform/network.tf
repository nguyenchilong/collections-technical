resource "aws_internet_gateway" "demo-igw" {
  vpc_id = aws_vpc.demo-vpc.id
}

resource "aws_route_table" "pub-rt" {
    vpc_id = aws_vpc.demo-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo-igw.id
    }
    tags = {
        Name = "pub-rt"
    }
}

resource "aws_route_table_association" "rt-1"{
    subnet_id = aws_subnet.public-subnet-2.id
    route_table_id = aws_route_table.pub-rt.id
}

resource "aws_eip" "demo-eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "demo-ngw" {
    allocation_id = aws_eip.demo-eip.id
    subnet_id = aws_subnet.public-subnet-1.id
}

resource "aws_route_table" "pri-rt" {
  vpc_id = aws_vpc.demo-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.demo-ngw.id
  }
  tags = {
    Name = "pri-rt"
  }
}

resource "aws_route_table_association" "rt-2" {
  subnet_id = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.pri-rt.id
}

resource "aws_security_group" "demo-sg" {
    vpc_id = aws_vpc.demo-vpc.id
    ingress {
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
    Name = "demo-sg"
  }
}