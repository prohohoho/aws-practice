# for getting my ip 
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# create aws vpc instance
resource "aws_vpc" "vpc_test" {
  cidr_block = "${var.vpc_ip}"

  tags = {
    Name = "aws-test"
  }
}

resource "aws_subnet" "subnet_test_pub" {
  vpc_id            = "${aws_vpc.vpc_test.id}"
  cidr_block        = "172.16.10.0/24"
  availability_zone = "ap-southeast-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "aws-test"
  }
 depends_on           = [aws_vpc.vpc_test] 
}

resource "aws_subnet" "subnet_test_priv" {
  vpc_id            = "${aws_vpc.vpc_test.id}"
  cidr_block        = "172.16.20.0/24"
  availability_zone = "ap-southeast-2a"
  tags = {
    Name = "aws-test"
  }
  depends_on           = [aws_vpc.vpc_test] 
}

resource "aws_internet_gateway" "ig_test" {
 vpc_id = "${aws_vpc.vpc_test.id}"
 
 tags = { 
  Name = "ig_test"
 }
 depends_on           = [aws_security_group.sg_test]
}

#resource "aws_network_interface" "ni_test" {
#  subnet_id   = "${aaws_subnet.subnet_test.id}"
#  private_ips = ["172.16.10.100"]
#
#  tags = {
#    Name = "aws-test"
#  }
#}

# create aws security group instance
resource "aws_security_group" "sg_test" {
 name = "aws-practice-sg2"
 vpc_id = "${aws_vpc.vpc_test.id}"
 
 ingress {
  description = "SSH"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
 }
 
 egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
 }

 tags = {
  Name = "aws-test"
 }
 depends_on           = [aws_subnet.subnet_test_priv , aws_subnet.subnet_test_pub]
}

# create aws ec2 instance
resource "aws_instance" "ec2_test" {
  ami           = "${var.ami_id}" 
  instance_type = "${var.instance_type}" 
  vpc_security_group_ids = [aws_security_group.sg_test.id]
  subnet_id = "${aws_subnet.subnet_test_pub.id}" 
  #vpc_id = [aws_vpc.vpc_test.id]

  tags = {
    Name = "aws-test"
  }
  depends_on           = [aws_security_group.sg_test ,aws_vpc.vpc_test]
}

