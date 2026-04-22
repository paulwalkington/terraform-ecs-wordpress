module "rds_wp_db" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name                = "${local.prefix}-wp-cluster"
  database_name       = "wordpress_db"
  engine                    = "aurora-mysql"
  engine_version            = "5.7.mysql_aurora.2.11.6"
  cluster_instance_class      = "db.t3.small"
  skip_final_snapshot = true
  instances = {
    one = {
      publicly_accessible = true
    }
  }

    security_group_ingress_rules = {

    ingress_from_ecs = {
      from_port                = 3306
      to_port                  = 3306
      ip_protocol              = "tcp"
      referenced_security_group_id = module.ecs_service.security_group_id
    }
    # access from everywhere
    # ingress = {
    #   from_port   = 3306
    #   to_port     = 3306
    #   ip_protocol    = "tcp"
    #   cidr_ipv4 = "0.0.0.0/0"
    # }
  }

  master_username             = "dev_mysql_user"
  manage_master_user_password = true

  vpc_id = module.vpc.vpc_id

  db_subnet_group_name   = "${local.prefix}-wp-cluster"
  subnets                = module.vpc.public_subnets
  create_db_subnet_group = true

  storage_encrypted   = true
  apply_immediately   = true

  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
}