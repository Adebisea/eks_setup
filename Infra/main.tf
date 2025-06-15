provider "aws" {
  region = "us-east-1"
}

module "vpc" {
    source = "./VPC"
}
module "eks"{
    source = "./EKS"
    subnet_ids = [module.vpc.pub1_subnet_id,
                  module.vpc.pub2_subnet_id,
                  module.vpc.prv1_subnet_id,
                  module.vpc.prv2_subnet_id,
                  module.vpc.prv3_subnet_id]
}


# create s3 bucket to store terraform state file.
resource "aws_s3_bucket" "bucket" {
  bucket = "tf-state-techn"

  tags = {
    Name        = "tf_bucket"
    Environment = var.environment
  }
}

terraform {
  backend "s3" {
    bucket         = "tf-state-techn"
    key            = "${var.environment}-terraform.tfstate"
}
}
