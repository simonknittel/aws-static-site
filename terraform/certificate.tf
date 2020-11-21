resource "aws_acm_certificate" "certificate" {
  provider = aws.for_certificates # Certificates for Cloudfront must be stored in us-east-1

  domain_name = local.full_domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

# TODO: www.
