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
# Terraform Cloud 
data "terraform_remote_state" "network_state" {
  backend = "remote"
  config = {
    organization = "bbphoenix"
    workspaces = {
      name = "folder_1-network"
    }
  }
}
