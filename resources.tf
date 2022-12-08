# for getting my ip 
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

//network.tf
resource "aws_vpc" "test-env" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "test-env"
  }
}

//subnets.tf
resource "aws_subnet" "subnet-uno" {
  cidr_block = "${cidrsubnet(aws_vpc.test-env.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.test-env.id}"
  availability_zone = "ap-southeast-2a"
}

//security.tf
resource "aws_security_group" "ingress-all-test" {
  name = "allow-all-sg"
  vpc_id = "${aws_vpc.test-env.id}"
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }
  // Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
 }


//servers.tf
resource "aws_instance" "test-ec2-instance" {
  ami = "ami-0df609f69029c9bdb"
  instance_type = "t2.micro"
  key_name = "aws-practice-kp"
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
  tags= {
    Name = "aws-test"
  }
  subnet_id = "${aws_subnet.subnet-uno.id}"
   depends_on     = [aws_security_group.ingress-all-test]
}



resource "aws_eip" "ip-test-env" {
  instance = "${aws_instance.test-ec2-instance.id}"
  vpc      = true
}

//gateways.tf
resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = "${aws_vpc.test-env.id}"
  tags={
    Name = "test-env-gw"
  }
}

//subnets.tf
resource "aws_route_table" "route-table-test-env" {
  vpc_id = "${aws_vpc.test-env.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }
  tags ={
    Name = "test-env-route-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-uno.id}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}