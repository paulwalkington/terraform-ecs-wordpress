module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  name = "${local.prefix}-wp-cluster"
}