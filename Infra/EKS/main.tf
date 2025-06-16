# iam role for eks
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Eks Role Cluster Policy
resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Eks Role Compute Policy
resource "aws_iam_role_policy_attachment" "eks_ComputePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.eks_role.name
}

# Eks Role EBS Policy
resource "aws_iam_role_policy_attachment" "eks_ebs_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.eks_role.name
}

# Eks Role ELB Policy
resource "aws_iam_role_policy_attachment" "eks_elb_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.eks_role.name
}

# Eks Role Networking Policy
resource "aws_iam_role_policy_attachment" "eks_np_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.eks_role.name
}

# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS Cluster Security Group"
  vpc_id      = var.vpc_id

  # Allow incoming traffic from worker nodes SG
  ingress {
    description = "Allow worker nodes to communicate with the cluster API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.worker_node_subnet_cidr_blocks
  }

  # Allow all egress traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
    environment = var.environment
  }
}


# Eks configuration
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = var.subnet_ids
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
  depends_on = [aws_iam_role_policy_attachment.eks_policy,
                aws_iam_role_policy_attachment.eks_ComputePolicy,
                aws_iam_role_policy_attachment.eks_ebs_Policy,
                 aws_iam_role_policy_attachment.eks_elb_Policy,
                  aws_iam_role_policy_attachment.eks_np_Policy]

    tags = {
            environment = var.environment
          }
}

#eks worker nodes

# Worker Node Security Group
resource "aws_security_group" "eks_node_sg" {
  name        = "${var.cluster_name}-node-sg"
  description = "EKS Worker Nodes Security Group"
  vpc_id      = var.vpc_id

  # Allow node-to-node communication
  ingress {
    description = "Allow nodes to communicate with each other"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  # Allow incoming traffic from cluster SG (control plane)
  ingress {
    description = "Allow cluster control plane to communicate with nodes"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_cluster_sg.id]
  }

  # Allow all egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-node-sg"
  }
}

# Worker Node IAM Role
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Policy to allow worker node to pull image from ECR 
resource "aws_iam_role_policy_attachment" "node_ecr_PullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.eks_node_role.name
}

# Worker Node Policy  
resource "aws_iam_role_policy_attachment" "eks_worker_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Policy to allow worker node read access to ECR 
resource "aws_iam_role_policy_attachment" "node_ecr_ReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# Filtering for Ubuntu Eks ami 
data "aws_ami_ids" "ubuntu" {
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu-eks/k8s_${var.k8s_version}/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  sort_ascending = true

}

#  Launch template for worker node 
resource "aws_launch_template" "ubuntu_lt" {
  name_prefix   = "ubuntu-eks-nodegroup"
  image_id      = data.aws_ami_ids.ubuntu.ids[0]  
  instance_type  = var.node_instance_type

  network_interfaces {
    security_groups = [aws_security_group.eks_node_sg.id]
  }
}


resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  ami_type        = var.ami_type
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids 
  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_capacity
    min_size     = var.min_capacity
  }

  launch_template {
    id      = aws_launch_template.ubuntu_lt.id
    version = "$Latest"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_worker_policy,
                aws_iam_role_policy_attachment.node_ecr_PullOnly,
                aws_iam_role_policy_attachment.node_ecr_ReadOnly
             ]
              
  tags = {
            environment = var.environment
          }
}
