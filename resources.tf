
resource "aws_vpc" "my_vpc" {
  cidr_block = "${var.vpc_ip}"

  tags = {
    Name = "aws-test"
  }
}

resource "aws_security_group" "my_sg" {
 name = "aws-practice-sg2"
 description = "This firewall allows SSH, HTTP and MYSQL"
 vpc_id = "${aws_vpc.my_vpc.id}"
 
 ingress {
  description = "SSH"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [format("%s/%s",data.external.whatismyip.result["internet_ip"],32)]
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
  Name = "aws-test"
 }
 depends_on           = [aws_vpc.my_vpc]
}

# create aws ec2 instance
resource "aws_instance" "web" {
  ami           = "${var.aws_secret}" 
  instance_type = "${var.instance_type}" 
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  vpc_id = [aws_vpc.my_vpc.id]

  tags = {
    Name = "aws-test"
  }
  depends_on           = [aws_security_group.my_sg ,aws_vpc.my_vpc]
}

