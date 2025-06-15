

variable "cluster_name" {
  default = "eks-app-cluster"
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "desired_capacity" {
  default = 2
}

variable "max_capacity" {
  default = 3
}

variable "min_capacity" {
  default = 2
}

variable "subnet_ids"{
  type = list(string)
}

variable "ami_type" {
  default = "AL2_x86_64"
}

variable "environment" {
  type        = string
}