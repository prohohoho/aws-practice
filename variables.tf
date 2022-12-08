#------------VNET------------------

variable "aws_region" {
    description = "aws region"
    default     = "ap-southeast-2"
}

variable "ami_id" {
    description = "aws ami ID"
    default     = "ami-0df609f69029c9bdb"
    #default     ="ami-06bb074d1e196d0d4"
}

variable "vpc_ip" {
    description = "VNET address prefix"
    default     = "192.168.0.0/16"
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

variable "dd_values_path" {
  description = "The filepath for the datadog values file"
  #number of dots state how many folders back to check
  default ="./TfState/tform.tfstate"
}