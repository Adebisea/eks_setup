provider "aws" {
  region = "eu-west-1"
}


terraform {
  backend "s3" {
    bucket = "tf-state-techn"
    key    = "prod/terraform.tfstate"
    region = "eu-west-1"
  }
}


module "vpc" {
  source = "./VPC"
  prefix = "sharks-${ var.environment}"
  environment = var.environment

}
module "eks" {
  source = "./EKS"
  vpc_id   = module.vpc.vpc_id
  k8s_version = "1.32"
  environment = var.environment
  subnet_ids = [
    module.vpc.prv1_subnet_id,
    module.vpc.prv2_subnet_id,
  module.vpc.prv3_subnet_id]
}


# create s3 bucket to store terraform state file.
# resource "aws_s3_bucket" "bucket" {
#   bucket = "tf-state-techn"

#   tags = {
#     Name        = "tf_bucket"
#     Environment = var.environment
#   }
# }

