locals {
  aws_load_balancer_controller_sa = "aws-load-balancer-controller"
}
# to get the oidc issuer url after eksctl associate
data "aws_eks_cluster" "phx_eks_post_association" {
  name       = "phx_eks"
  depends_on = [aws_iam_openid_connect_provider.eks_oidc_association]
}

# to get the oidc arn
# data "external" "oidc" {
#   program    = ["/bin/bash", "-c", "aws iam list-open-id-connect-providers | jq '.OpenIDConnectProviderList[0]'"]
#   depends_on = [null_resource.eks_oidc_association]
# }

# IAM role for oidc:aws-lb-controller-sa
resource "aws_iam_role" "phx_eks_load_balancer_controller_role" {
  name = "phx_eks_load_balancer_controller_role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRoleWithWebIdentity",
          "Principal" : {
            "Federated" : aws_iam_openid_connect_provider.eks_oidc_association.arn
          },
          "Condition" : {
            "StringEquals" : {
              "${trimprefix(data.aws_eks_cluster.phx_eks_post_association.identity[0].oidc[0].issuer, "https://")}:sub" : [
                "system:serviceaccount:kube-system:${local.aws_load_balancer_controller_sa}"
              ]
            }
          }
        }
      ]
    }
  )
  depends_on = [data.aws_eks_cluster.phx_eks_post_association]
}

# AWS lb_controller_policy
data "http" "aws_lb_controller_policy_json" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.3.1/docs/install/iam_policy.json"

  # Optional request headers
  request_headers = {
    Accept = "application/json"
  }
}
# attach lb_controller policy to oidc:aws-lb-controller-role 
resource "aws_iam_role_policy" "phx_aws_load_balancer_controller_iam_role_policy" {
  name   = "phx_aws_load_balancer_controller_iam_policy"
  role   = aws_iam_role.phx_eks_load_balancer_controller_role.id
  policy = data.http.aws_lb_controller_policy_json.body
}

# Create sa for aws-lb-controller
resource "kubernetes_service_account" "phx_aws_load_balancer_controller_sa" {
  metadata {
    name      = local.aws_load_balancer_controller_sa
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/component" : "controller"
      "app.kubernetes.io/name" : local.aws_load_balancer_controller_sa
    }
    annotations = { "eks.amazonaws.com/role-arn" : aws_iam_role.phx_eks_load_balancer_controller_role.arn }

  }
  depends_on = [aws_iam_role_policy.phx_aws_load_balancer_controller_iam_role_policy]
}

# import eks charts
# resource "null_resource" "add_eks_repo" {
#   provisioner "local-exec" {
#     command = "helm repo add eks https://aws.github.io/eks-charts; helm repo update"
#   }
# }

# Deploy AWS load balancer controller
resource "helm_release" "aws_load_balancer_controller_helm_release" {
  name              = "aws-load-balancer-controller"
  dependency_update = true
  repository        = "https://aws.github.io/eks-charts"
  chart             = "aws-load-balancer-controller"
  namespace         = "kube-system"

  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.phx_eks_post_association.name
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = local.aws_load_balancer_controller_sa
  }
}
