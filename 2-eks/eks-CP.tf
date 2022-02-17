resource "aws_eks_cluster" "phx_eks" {
  name     = "phx_eks"
  role_arn = aws_iam_role.phx_eks_cluster_service_role.arn

  vpc_config {
    subnet_ids = [data.terraform_remote_state.network_state.outputs.phx_private_subnet_1.id, data.terraform_remote_state.network_state.outputs.phx_private_subnet_2.id]
    # security_group_ids      = [data.terraform_remote_state.network_state.outputs.phx_private_sg.id]
    endpoint_public_access = true
  }

  kubernetes_network_config {
    service_ipv4_cidr = "172.16.0.0/16"
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.policy_attatchment_to_phx_eks_cluster_service_role
  ]
}

resource "aws_iam_role" "phx_eks_cluster_service_role" {
  name               = "phx_eks_cluster_service_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "policy_attatchment_to_phx_eks_cluster_service_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.phx_eks_cluster_service_role.name
}
