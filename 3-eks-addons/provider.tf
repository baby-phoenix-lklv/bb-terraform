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
    organization = "babyphoenix"
    workspaces = {
      name = "prod-eks"
    }
  }
}

data "aws_eks_cluster_auth" "phx_eks_auth_token" {
  name = data.terraform_remote_state.eks_state.outputs.phx_eks.name
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks_state.outputs.phx_eks.endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_state.outputs.phx_eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.phx_eks_auth_token.token
}
provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks_state.outputs.phx_eks.endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_state.outputs.phx_eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.phx_eks_auth_token.token
  }
}
