data "aws_ec2_managed_prefix_list" "cloudfront_prefix_list" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

module "elb-wp-frontend" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.9.0"

  name    = "${local.prefix}-wp-frontend"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  load_balancer_type         = "application"
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    cloudfront_http = {
      from_port      = 80
      to_port        = 80
      ip_protocol    = "tcp"
      description    = "HTTP web traffic from CloudFront only"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    ecs = {
      from_port                    = 80
      to_port                      = 80
      ip_protocol                  = "tcp"
      description                  = "ECS access"
      referenced_security_group_id = module.ecs_service.security_group_id
    }
  }



  target_groups = {
    "${local.prefix}-ecs-wp-service" = {
      name              = "${local.prefix}-wp-service"
      protocol          = "HTTP"
      port              = 80
      target_type       = "ip"
      vpc_id            = module.vpc.vpc_id
      create_attachment = false

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    }
  }


  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"

      fixed_response = {
        content_type = "text/plain"
        message_body = "Access denied"
        status_code  = "403"
      }

      rules = {
        allow_cloudfront = {
          priority = 1
          conditions = [
            {
              http_header = {
                http_header_name = "X-Allow"
                values           = ["super_secret_token"]
              }
            }
          ]
          actions = [
            {
              type             = "forward"
              target_group_key = "${local.prefix}-ecs-wp-service"
            }
          ]
        }
      }
    }
  }
}

