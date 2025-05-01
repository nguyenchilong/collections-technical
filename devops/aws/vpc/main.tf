# VPC 1 (Web Application VPC)
## Public Subnet: Application Load Balancer (ALB): Handles incoming traffic and directs it to the web servers in the private subnet.
## Private Subnet: Web Servers (EC2 Instances): Run the application and process requests. These instances are isolated in the private subnet for security.

provider "aws" {
	region = "ap-south-1"
}

resource "aws_vpc" "ins_vpc" {
	cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "ins_pub_subnet_1a" {
	cidr_block              = "10.0.1.0/24"
	vpc_id                  = aws_vpc.ins_vpc.id
	availability_zone       = "ap-south-1a"
	map_public_ip_on_launch = true
}

resource "aws_subnet" "ins_pub_subnet_1b" {
	cidr_block              = "10.0.2.0/24"
	vpc_id                  = aws_vpc.ins_vpc.id
	availability_zone       = "ap-south-1b"
	map_public_ip_on_launch = true
}

resource "aws_subnet" "ins_pri_subnet_1a" {
	cidr_block              = "10.0.3.0/24"
	vpc_id                  = aws_vpc.ins_vpc.id
	map_public_ip_on_launch = false
	availability_zone       = "ap-south-1a"
}

# Security Groups:
## ALB Security Group: Allows inbound HTTP/HTTPS traffic from the internet.
## Web Server Security Group: Allows inbound traffic only from the ALB’s security group on the required ports (e.g., port 80 or 443).
## RDS Security Group: Allows inbound traffic only from the web server’s security group in VPC 1 on the database port (e.g., port 3306 for MySQL).

resource "aws_security_group" "ins_sg" {
	vpc_id = aws_vpc.ins_vpc.id
	ingress {
		from_port = 80
		to_port   = 80
		protocol  = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		security_groups = [aws_security_group.lb_sg.id]
	}
	
	ingress {
		from_port = 8080
		to_port   = 8080
		protocol  = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		security_groups = [aws_security_group.lb_sg.id]
	}
	
	ingress {
		from_port = 22
		to_port   = 22
		protocol  = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		security_groups = [aws_security_group.lb_sg.id]
	}
	
	ingress {
		from_port = 3306
		to_port   = 3306
		protocol  = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	egress {
		from_port = 0
		to_port   = 0
		protocol  = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

# Load Balancer Security Group
resource "aws_security_group" "lb_sg" {
	vpc_id = aws_vpc.ins_vpc.id
	ingress {
		from_port = 80
		to_port   = 80
		protocol  = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port = 8080
		to_port   = 8080
		protocol  = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	egress {
		from_port = 0
		to_port   = 0
		protocol  = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

# NAT Gateway and Routing Table:
resource "aws_internet_gateway" "ig" {
	vpc_id = aws_vpc.ins_vpc.id
}

resource "aws_route_table" "rt" {
	vpc_id = aws_vpc.ins_vpc.id
	route {
		gateway_id = aws_internet_gateway.ig.id
		cidr_block = "0.0.0.0/0"
	}
}

resource "aws_route_table_association" "rta_1a" {
	route_table_id = aws_route_table.rt.id
	subnet_id      = aws_subnet.ins_pub_subnet_1a.id
}

resource "aws_route_table_association" "rta_1b" {
	route_table_id = aws_route_table.rt.id
	subnet_id      = aws_subnet.ins_pub_subnet_1b.id
}

resource "aws_eip" "eip" {

}

resource "aws_nat_gateway" "nat" {
	subnet_id     = aws_subnet.ins_pub_subnet_1a.id
	allocation_id = aws_eip.eip.id
}

resource "aws_route_table" "nat_rt" {
	vpc_id = aws_vpc.ins_vpc.id
	route {
		nat_gateway_id = aws_nat_gateway.nat.id
		cidr_block     = "0.0.0.0/0"
	}
}

resource "aws_route_table_association" "nat_rta" {
	route_table_id = aws_route_table.nat_rt.id
	subnet_id      = aws_subnet.ins_pri_subnet_1a.id
}

## Load Balancer and Target Groups

resource "aws_lb" "lb" {
	internal           = false
	load_balancer_type = "application"
	subnets = [aws_subnet.ins_pub_subnet_1a.id, aws_subnet.ins_pub_subnet_1b.id]
	security_groups = [aws_security_group.lb_sg.id]
}

resource "aws_lb_listener" "listener" {
	port              = 80
	protocol          = "HTTP"
	load_balancer_arn = aws_lb.lb.arn
	default_action {
		target_group_arn = aws_lb_target_group.tg.arn
		type             = "forward"
	}
}

resource "aws_lb_target_group" "tg" {
	port     = 8080
	protocol = "HTTP"
	vpc_id   = aws_vpc.ins_vpc.id
}

resource "aws_lb_target_group_attachment" "tga" {
	target_group_arn = aws_lb_target_group.tg.arn
	target_id        = aws_instance.instance.id
	port             = 8080
}

## EC2 Instance
resource "aws_instance" "instance" {
	ami           = "ami-0522ab6e1ddcc7055"
	instance_type = "t2.micro"
	subnet_id     = aws_subnet.ins_pri_subnet_1a.id
	security_groups = [aws_security_group.ins_sg.id]
	user_data     = data.template_file.user_data.rendered
	key_name      = "aws-learning"
	depends_on = [
		aws_nat_gateway.nat,
		aws_route_table_association.nat_rta,
		aws_db_instance.default
	]
}

resource "aws_instance" "bastian" {
	ami                         = "ami-0522ab6e1ddcc7055"
	instance_type               = "t2.micro"
	subnet_id                   = aws_subnet.ins_pub_subnet_1a.id
	security_groups = [aws_security_group.ins_sg.id]
	associate_public_ip_address = true
	key_name                    = "aws-learning"
}

# RDS
variable "rds_address" {
	type    = string
	default = "value"
}

resource "aws_vpc" "rds_vpc" {
	cidr_block = "212.0.0.0/16"
}

resource "aws_subnet" "rds_subnet_1a" {
	cidr_block              = "212.0.1.0/24"
	vpc_id                  = aws_vpc.rds_vpc.id
	map_public_ip_on_launch = false
	availability_zone       = "ap-south-1a"
}

resource "aws_subnet" "rds_subnet_1b" {
	cidr_block              = "212.0.2.0/24"
	vpc_id                  = aws_vpc.rds_vpc.id
	map_public_ip_on_launch = false
	availability_zone       = "ap-south-1b"
}

resource "aws_db_subnet_group" "rds_subg" {
	name = "mysqldb"
	subnet_ids = [aws_subnet.rds_subnet_1a.id, aws_subnet.rds_subnet_1b.id]
}
resource "aws_security_group" "rds_sg" {
	vpc_id = aws_vpc.rds_vpc.id
	ingress {
		protocol  = "tcp"
		from_port = "3306"
		to_port   = "3306"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	egress {
		protocol  = "-1"
		from_port = 0
		to_port   = 0
		cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_route_table" "rda_rt" {
	vpc_id = aws_vpc.rds_vpc.id
}

resource "aws_route_table_association" "rds_rta_1a" {
	subnet_id      = aws_subnet.rds_subnet_1a.id
	route_table_id = aws_route_table.rda_rt.id
}

resource "aws_route_table_association" "rds_rta_1b" {
	subnet_id      = aws_subnet.rds_subnet_1b.id
	route_table_id = aws_route_table.rda_rt.id
}

resource "aws_db_instance" "default" {
	allocated_storage    = 10
	db_name              = "mydb"
	engine               = "mysql"
	engine_version       = "8.0"
	instance_class       = "db.t3.micro"
	username             = "root"
	password             = "root123456"
	parameter_group_name = "default.mysql8.0"
	skip_final_snapshot  = true
	vpc_security_group_ids = [aws_security_group.rds_sg.id]
	db_subnet_group_name = aws_db_subnet_group.rds_subg.id
	storage_type         = "gp2"
	publicly_accessible  = false
}

# VPC Peering Connection
## VPC Peering: Establishes a private connection between the two VPCs, allowing resources in VPC 1 to securely communicate with the RDS database in VPC 2. This connection does not traverse the public internet.

resource "aws_vpc_peering_connection" "vpc_peer" {
	vpc_id      = aws_vpc.ins_vpc.id
	peer_vpc_id = aws_vpc.rds_vpc.id
	auto_accept = true
}

resource "aws_route" "route" {
	route_table_id            = aws_route_table.nat_rt.id
	destination_cidr_block    = aws_vpc.rds_vpc.cidr_block
	vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}

resource "aws_route" "route_rds" {
	route_table_id            = aws_route_table.rda_rt.id
	destination_cidr_block    = aws_vpc.ins_vpc.cidr_block
	vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peer.id
}
