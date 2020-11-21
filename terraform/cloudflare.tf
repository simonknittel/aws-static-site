provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "cloudflare_zones" "main" {
  filter {
    name = var.cloudflare_zone_name
    lookup_type = "exact"
  }
}

resource "cloudflare_record" "certificate_validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options: dvo.domain_name => {
      name   = dvo.resource_record_name
      value = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.cloudflare_zones.main.zones[0].id
  name = each.value.name
  value = each.value.value
  type = each.value.type
  proxied = false
}

resource "cloudflare_record" "a" {
  zone_id = data.cloudflare_zones.main.zones[0].id
  name = var.subdomain
  value = aws_cloudfront_distribution.distribution.domain_name
  type = "CNAME"
  proxied = false
}

# TODO: www.
