provider "aws" {
  region  ="ap-south-1"
  profile  ="myvidhi"
}

resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "lwvpc3"
  }
}

resource "aws_subnet" "mypublicsubnet1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "lwsubnet31"
  }
}

resource "aws_subnet" "myprivatesubnet2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "192.168.32.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "lwsubnet32"
  }
}
resource "aws_internet_gateway" "myvidhiig" {
  vpc_id = "${aws_vpc.main.id}" 

  tags = {
    Name = "lwig3"
  }
}
resource "aws_route_table" "myvidhirt" {
  vpc_id = "${aws_vpc.main.id}" 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myvidhiig.id}"
  }

  tags = {
    Name = "lwrt3"
  }   
}

resource "aws_route_table_association" "mya" {
  subnet_id = aws_subnet.mypublicsubnet1.id
  route_table_id = aws_route_table.myvidhirt.id
}

resource "aws_route_table_association" "myb" {
  subnet_id = aws_subnet.myprivatesubnet2.id
  route_table_id = aws_route_table.myvidhirt.id
}

resource "aws_security_group" "vidhi_sg1"{
  name = "vidhi_sg1"
  vpc_id = "${aws_vpc.main.id}" 

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    description = "TCP"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 
  
  egress { 
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "lwsg3"
 }
}

resource "aws_instance" "vidhiins"{
  ami = "ami-96d6a0f9"
  instance_type = "t2.micro"
  key_name = "vidhikey"
  vpc_security_group_ids = [aws_security_group.vidhi_sg1.id]
  subnet_id = "${aws_subnet.mypublicsubnet1.id}"

  tags = {
    Name = "task3wordpress"
  }
}

resource "aws_instance" "vidhiins1"{
  ami = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  key_name = "vidhikey"
  vpc_security_group_ids = [aws_security_group.vidhi_sg1.id]
  subnet_id = "${aws_subnet.myprivatesubnet2.id}"

  tags = {
    Name = "task3mysql"
  }
}