data "aws_subnet_ids" "private_subnets" {
  vpc_id = data.terraform_remote_state.network_state.outputs.phx_vpc.id
  tags = {
    Tier = "private"
  }
}

resource "aws_eks_node_group" "phx_eks_node_group" {
  cluster_name    = aws_eks_cluster.phx_eks.name
  node_group_name = "phx_eks_node_group"
  node_role_arn   = aws_iam_role.phx_eks_node_group_role.arn
  subnet_ids      = data.aws_subnet_ids.private_subnets.ids[*]

  instance_types = ["t2.medium"]
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.phx_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.phx_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.phx_AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "phx_eks_node_group_role" {
  name = "phx_eks_node_group_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "phx_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.phx_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "phx_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.phx_eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "phx_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.phx_eks_node_group_role.name
}
