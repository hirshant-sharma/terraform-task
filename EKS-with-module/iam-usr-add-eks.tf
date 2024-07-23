resource "aws_iam_user" "eks_user" {
  name = "ECR_USR"
}

resource "aws_iam_user_policy_attachment" "eks_user_policy_attach" {
  user       = aws_iam_user.eks_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_eks_cluster" "my_cluster" {
  name = "prod-eks"
}

data "aws_eks_cluster_auth" "my_cluster" {
  name = data.aws_eks_cluster.my_cluster.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.my_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.my_cluster.token
}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = jsonencode([
      {
        userarn  = aws_iam_user.eks_user.arn
        username = "eks-user"
        groups   = ["system:masters"]
      }
    ])
  }

  depends_on = [ data.aws_eks_cluster.my_cluster ]
}

