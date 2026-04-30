resource "aws_cloudfront_origin_request_policy" "allow_custom_headers" {
  name    = "AllowCustomHeaders"
  comment = "Temporary policy to allow disassociation before delete"

  headers_config {
    header_behavior = "none"
  }

  query_strings_config {
    query_string_behavior = "none"
  }

  cookies_config {
    cookie_behavior = "none"
  }

  depends_on = [aws_cloudfront_distribution.cdn]
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = module.elb-wp-frontend.dns_name
    origin_id   = "alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    custom_header {
        name  = "X-Allow"
        value = "super_secret_token" // Please inject not set in clear text
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-origin"

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # Managed-CachingOptimized
    viewer_protocol_policy   = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "StaticSiteCloudFront"
  }
}