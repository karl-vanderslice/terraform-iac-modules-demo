locals {
  domain_name = trimsuffix(var.domain_name, ".")
}

data "cloudflare_zone" "cloudflare" {
  name = local.domain_name
}

# More or less adopted from the offical ACM module docs

# 1. create cert in AWS

resource "aws_acm_certificate" "cert" {
  domain_name               = "${var.environment_name}.${local.domain_name}"
  subject_alternative_names = [] # Don't need wildcards for this demo
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true

  }

  tags = var.tags

}

# 2. cloudflare records for validation

resource "cloudflare_record" "validation" {
  for_each = {
    for item in aws_acm_certificate.cert.domain_validation_options : item.domain_name => {
      name   = item.resource_record_name
      record = item.resource_record_value
      type   = item.resource_record_type
    }
  }

  zone_id         = data.cloudflare_zone.cloudflare.id
  allow_overwrite = true
  proxied         = false
  name            = each.value.name
  type            = each.value.type
  value           = each.value.record
  ttl             = 1 # Needed?

}

# 3. validate ACM with created records

resource "aws_acm_certificate_validation" "cloudflare" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in cloudflare_record.validation : record.hostname]
}