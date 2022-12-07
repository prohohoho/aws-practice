terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "${var.aws_region}"
  access_key = "${var.aws_clientid}"
  secret_key = "${var.aws_secret}"
}
