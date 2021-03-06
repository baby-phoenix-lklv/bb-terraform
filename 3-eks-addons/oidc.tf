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
# resource "null_resource" "eks_oidc_association" {
#   triggers = {
#     eks_name = "phx_eks"
#   }
#   provisioner "local-exec" {
#     command = <<-EOT
#     sudo curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
#     /tmp/eksctl utils associate-iam-oidc-provider --cluster  ${data.terraform_remote_state.eks_state.outputs.phx_eks.name} --approve
#     EOT
#   }
#   provisioner "local-exec" {
#     when    = destroy
#     command = "aws iam delete-open-id-connect-provider --open-id-connect-provider-arn $(aws iam list-open-id-connect-providers | jq -r '.OpenIDConnectProviderList[0].Arn')  "
#   }
# }

data "tls_certificate" "tls_cert" {
  url = data.terraform_remote_state.eks_state.outputs.phx_eks.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc_association" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.tls_cert.certificates.0.sha1_fingerprint]
  url             = data.terraform_remote_state.eks_state.outputs.phx_eks.identity.0.oidc.0.issuer
}
