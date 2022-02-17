output "phx_eks" {
  value = aws_eks_cluster.phx_eks
}
data "aws_region" "current_region" {}
locals {
  eks_cli_command = "aws eks update-kubeconfig --region ${data.aws_region.current_region.name} --name ${aws_eks_cluster.phx_eks.name}"
}
output "update_kubeconfig_command" {
  value = local.eks_cli_command
}
