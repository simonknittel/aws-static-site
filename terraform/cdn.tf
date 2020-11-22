resource "aws_acm_certificate" "certificate" {
  provider = aws.for_certificates # Certificates for Cloudfront must be stored in us-east-1

  domain_name = local.full_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {}

resource "aws_cloudfront_distribution" "distribution" {
  enabled = true
  price_class = "PriceClass_All"
  is_ipv6_enabled = true
  default_root_object = "index.html"

  aliases = [ local.full_domain ]

  origin {
    origin_id = "origin-${aws_s3_bucket.bucket.id}"
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "origin-${aws_s3_bucket.bucket.id}"
    viewer_protocol_policy = "redirect-to-https"
    compress = true

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.certificate.arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method = "sni-only"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }

  custom_error_response {
    error_code = 404
    response_code = 404
    response_page_path = "/404.html"
  }

  custom_error_response {
    error_code = 500
    response_code = 500
    response_page_path = "/5xx.html"
  }
}
