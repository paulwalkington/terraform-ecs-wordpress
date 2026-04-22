output "load_balancer_url" {
  value = module.elb-xdm-frontend.dns_name
}

output "database_endpoint" {
  value = module.rds_xdm_db.cluster_endpoint
}

output "ecr_repo_image_url" {
  value = aws_ecr_repository.ecr-repository.repository_url
}

