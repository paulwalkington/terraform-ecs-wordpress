resource "aws_ecr_repository" "ecr-repository" {
  name         = "${local.prefix}-ecr-repository"
  force_delete = true
}