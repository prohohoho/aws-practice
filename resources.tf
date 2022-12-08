# for getting my ip 
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

//create vpc
resource "aws_vpc" "aws-test-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "aws-test-vpc"
  }
}

//create subnet
resource "aws_subnet" "aws-subnet-test" {
  cidr_block = "${cidrsubnet(aws_vpc.aws-test-vpc.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.aws-test-vpc.id}"
  availability_zone = "ap-southeast-2a"
}

//create securfity group
resource "aws_security_group" "aws-sg-test" {
  name = "ssh allow my local ip"
  vpc_id = "${aws_vpc.aws-test-vpc.id}"
  ingress {        
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  // Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
 }


//create ec2 t2.micro instance
resource "aws_instance" "aws-ec2-test" {
  ami = "${var.ami_id}"
  instance_type = "t2.micro"
  key_name = "aws-practice-kp"
  security_groups = ["${aws_security_group.aws-sg-test.id}"]
  tags= {
    Name = "aws-test"
  }
  subnet_id = "${aws_subnet.aws-subnet-test.id}"
  
  user_data = <<-EOL
  #!/bin/bash -xe
  sudo ufw enable
  sudo ufw allow from 203.173.222.36 to any port 22
  sudo apt update
  sudo apt install -y apt-transport-https
  wget -qO - https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -sc) stable" | sudo tee /etc/apt/sources.list.d/docker.list
  sudo apt update
  sudo apt install -y docker-ce
  docker run -d -p 80:80 --name=ngjohnx --health-cmd ='curl --fail http://localhost || exit 1' --health-interval=10s --health-start-period=3m nginx:1.14 

  EOL

   depends_on     = [aws_security_group.aws-sg-test]
}



resource "aws_eip" "ip-aws-test-vpc" {
  instance = "${aws_instance.aws-ec2-test.id}"
  vpc      = true
  depends_on     = [aws_instance.aws-ec2-test]
}

//gateways.tf
resource "aws_internet_gateway" "aws-test-vpc-gw" {
  vpc_id = "${aws_vpc.aws-test-vpc.id}"
  tags={
    Name = "aws-test-vpc-gw"
  }
}

//subnets.tf
resource "aws_route_table" "route-table-aws-test-vpc" {
  vpc_id = "${aws_vpc.aws-test-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.aws-test-vpc-gw.id}"
  }
  tags ={
    Name = "aws-test-vpc-route-table"
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.aws-subnet-test.id}"
  route_table_id = "${aws_route_table.route-table-aws-test-vpc.id}"
}