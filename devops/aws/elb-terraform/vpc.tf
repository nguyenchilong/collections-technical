resource "aws_vpc" "demo-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_hostnames = "true"
    enable_dns_support = "true"
    instance_tenancy =  "default"
    tags = {
        Name = "demo-vpc"
    }
}

resource "aws_subnet" "public-subnet-1" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "${var.region}a"
    tags = {
        Name = "public-subnet-1"
    }
}

resource "aws_subnet" "public-subnet-2" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "${var.region}b"
    tags = {
        Name = "public-subnet-2"
    }
}

resource "aws_subnet" "private-subnet-1" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "${var.region}a"
    tags = {
        Name = "private-subnet-1"
    }
}

resource "aws_subnet" "private-subnet-2" {
    vpc_id = aws_vpc.demo-vpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "${var.region}b"
    tags = {
        Name = "private-subnet-2"
    }
}

resource "aws_key_pair" "sydney-region-key-pair" {
    key_name = "sydney-region-key-pair"
    public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "demo1" {
    ami = "${var.ami}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public-subnet-1.id}"
    associate_public_ip_address = "true"
    vpc_security_group_ids = ["${aws_security_group.demo-sg.id}"]
    key_name = "${aws_key_pair.sydney-region-key-pair.id}"
    tags = {
        Name = "demo1"
    }
}

resource "aws_instance" "demo2" {
    ami = "${var.ami}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.private-subnet-1.id}"
    vpc_security_group_ids = ["${aws_security_group.demo-sg.id}"]
    user_data = file("script.sh")
    key_name = "${aws_key_pair.sydney-region-key-pair.id}"
    tags = {
        Name = "demo2"
    }
}

resource "aws_instance" "demo3" {
    ami = "${var.ami}"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.private-subnet-2.id}"
    vpc_security_group_ids = ["${aws_security_group.demo-sg.id}"]
    user_data = file("script.sh")
    key_name = "${aws_key_pair.sydney-region-key-pair.id}"
    tags = {
        Name = "demo3"
    }
}