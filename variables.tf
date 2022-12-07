#------------VNET------------------

variable "aws_region" {
    description = "aws region"
    default     = "ap-southeast-2"
}

variable "ami_id" {
    description = "aws ami ID"
    #default     = "ami-0d21d42bea8de8b55"
    default     ="ami-06bb074d1e196d0d4"
}

variable "vpc_ip" {
    description = "VNET address prefix"
    default     = "172.16.0.0/16"
}


variable "aws_clientid" {
    description = "access key ID."
    default     = ""
}

variable "aws_secret" {
    description = "secret access key"
    default     = ""
}

variable "instance_type" {
    description = "instance type for ec2"
    default     = "t2.micro"
}