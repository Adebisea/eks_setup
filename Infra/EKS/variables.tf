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
  default = 3
}

variable "min_capacity" {
  default = 2
}

variable "subnet_ids"{
  type = list(string)
}

variable "ami_type" {
  default = "CUSTOM"
}

variable "environment" {
  type        = string
}

variable "k8s_version" {
  type        = string
}

variable "worker_node_subnet_cidr_blocks" {
  type = list(string)
  default = ["192.168.8.0/24", "192.168.10.0/24", "192.168.11.0/24"]
}