# create OIDC Provider for the cluster
data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "tls_certificate" "eks-sharks-cluster" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks-sharks-cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks-sharks-cluster.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer

}

# create iam role service account for ebs csi
module "ebs_csi_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"

  name = "EKS_EBS_CSI_DriverRole"

  attach_ebs_csi_policy = true

  oidc_providers = {
    this = {
      provider_arn               = aws_iam_openid_connect_provider.eks-sharks-cluster.arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

}

module "load_balancer_controller_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"

  name = "load-balancer-controller-irsa"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    this = {
      provider_arn               = aws_iam_openid_connect_provider.eks-sharks-cluster.arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

}
