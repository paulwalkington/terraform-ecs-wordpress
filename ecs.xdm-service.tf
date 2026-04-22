module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name = "${local.prefix}-xdm-service"

  cluster_arn = module.ecs_cluster.arn

  desired_count = 1
  cpu           = 1024
  memory        = 2048

  container_definitions = {

    xdm-app = {

      cpu       = 1024
      memory    = 2048
      essential = true
      image : "${aws_ecr_repository.ecr-repository.repository_url}:latest",
      readonlyRootFilesystem = false

      portMappings = [
        {
          containerPort : 80,
          hostPort : 80
        }
      ]

      environment = [
        # { name = "WORDPRESS_DB_HOST", value = "jdbc:postgresql://${module.rds_xdm_db.cluster_endpoint}:5432/${module.rds_xdm_db.cluster_database_name}" },
        { name = "WORDPRESS_DB_HOST", value = "${module.rds_xdm_db.cluster_endpoint}" },
        { name = "WORDPRESS_DB_NAME", value = "${module.rds_xdm_db.cluster_database_name}" },
        { name = "WORDPRESS_DB_USER", value = "${module.rds_xdm_db.cluster_master_username}" },
        # { name = "WORDPRESS_DB_PASSWORD", value = "h|>VI?JWvr2RCef4Ja2fI$b~GUsO" }
      ]

      secrets = [
        {
          name      = "WORDPRESS_DB_PASSWORD"
          valueFrom = "${tolist(module.rds_xdm_db.cluster_master_user_secret)[0].secret_arn}:password::"
        }
      ]

      enable_cloudwatch_logging = true
    }
  }


  load_balancer = {
    service = {
      target_group_arn = module.elb-xdm-frontend.target_groups["${local.prefix}-ecs-xdm-service"].arn
      container_name   = "xdm-app"
      container_port   = 80
    }
  }

  security_group_ingress_rules = { 
    alb_ingress = {
      description                  = "http from ALB"
      to_port                      = 80
      from_port                    = 80
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.elb-xdm-frontend.security_group_id
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  subnet_ids = module.vpc.private_subnets

  task_exec_secret_arns = ["${tolist(module.rds_xdm_db.cluster_master_user_secret)[0].secret_arn}"]

}
