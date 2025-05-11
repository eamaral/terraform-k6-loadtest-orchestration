provider "aws" {
  region = "us-east-1"
}

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "5.12.1"

  cluster_name = var.cluster_name
}
