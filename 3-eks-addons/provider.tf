terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.4.1"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
}
# Import state from eks workspace
data "terraform_remote_state" "eks_state" {
  backend = "remote"
  config = {
    organization = "bbphoenix"
    workspaces = {
      name = "folder_2-eks"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "arn:aws:eks:ap-southeast-1:759744877037:cluster/phx_eks"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "arn:aws:eks:ap-southeast-1:759744877037:cluster/phx_eks"
  }
}


