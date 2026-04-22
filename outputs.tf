output "load_balancer_url" {
  value = module.elb-wp-frontend.dns_name
}

output "database_endpoint" {
  value = module.rds_wp_db.cluster_endpoint
}

output "ecr_repo_image_url" {
  value = aws_ecr_repository.ecr-repository.repository_url
}

