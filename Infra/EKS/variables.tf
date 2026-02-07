variable  "vpc_id" {
  type        = string
}

variable "cluster_name" {
  default = "eks-sharks-cluster"
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "desired_capacity" {
  default = 2
}

variable "max_capacity" {
  default = 5
}

variable "min_capacity" {
  default = 3
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

variable "k8s_version" {
  type        = string
}

variable "vpc_cidr_block" {
    type    = string
    default = "192.168.0.0/16"

}
