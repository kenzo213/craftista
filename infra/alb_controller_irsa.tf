locals {
  cluster_name = "craftista-dev"
  lb_namespace = "kube-system"
  lb_sa_name   = "aws-load-balancer-controller"
}

data "aws_caller_identity" "current" {}

# OIDC issuer from the EKS module
locals {
  oidc_issuer = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn = module.eks.oidc_provider_arn
}

data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${local.lb_namespace}:${local.lb_sa_name}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(local.oidc_issuer, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "alb_controller" {
  name               = "craftista-dev-aws-load-balancer-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
  tags = {
    Project     = "craftista"
    Environment = "dev"
  }
}

# AWS Load Balancer Controller policy (official recommended permissions)
# Source: https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
# We embed it here so everything stays Terraform-managed.
resource "aws_iam_policy" "alb_controller" {
  name   = "craftista-dev-aws-load-balancer-controller-policy"
  policy = file("${path.module}/iam/alb_iam_policy.json")
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn  = aws_iam_policy.alb_controller.arn
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}
