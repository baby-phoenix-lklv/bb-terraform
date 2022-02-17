# this is too slow and not working, maybe check the thumbprint
# resource "aws_eks_identity_provider_config" " _oidc" {
#   cluster_name = data.terraform_remote_state.eks_state.outputs.phx_eks.name
#   oidc {
#     identity_provider_config_name = "phx_eks_oidc"
#     client_id                     = "sts.amazonaws.com"
#     issuer_url                    = data.terraform_remote_state.eks_state.outputs.phx_eks.identity[0].oidc[0].issuer
#   }
# }

# create/delete oidc provider for EKS
resource "null_resource" "eks_oidc_association" {
  triggers = {
    eks_name = "phx_eks"
  }
  provisioner "local-exec" {
    command = "eksctl utils associate-iam-oidc-provider --cluster  ${data.terraform_remote_state.eks_state.outputs.phx_eks.name} --approve"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "aws iam delete-open-id-connect-provider --open-id-connect-provider-arn $(aws iam list-open-id-connect-providers | jq -r '.OpenIDConnectProviderList[0].Arn')  "
  }
}
