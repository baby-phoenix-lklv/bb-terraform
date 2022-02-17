terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
}

data "terraform_remote_state" "network_state" {
  backend = "local"
  config = {
    path = "../1-network/terraform.tfstate"
  }
}
