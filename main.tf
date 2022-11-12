# Data sources

## Used for securing our Security Groups to allow ONLY ingress traffic from Cloudflare's known IP ranges (https://www.cloudflare.com/ips/)

data "cloudflare_ip_ranges" "cloudflare" {}

## Get our default VPC.  In a production scenario, we'd want to either include this as part of our solution, or use an existing non-default VPC as a data source or variable. 

data "aws_vpc" "default_vpc" {
  default = true
}

## Grab our public subnets - similar to above, in a production scenario we probably know this before time or can derive this better from tags we've pre-populated on a non-default VPC.

data "aws_subnets" "public_subnet_ids" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# Locals - for this solution.  These should ideally be workspace variables we pass in.

locals {
  environment_name     = var.environment_name
  cloudflare_zone_name = trimsuffix(var.cloudflare_zone_name, ".")
}

data "cloudflare_zone" "cloudflare" {
  name = var.cloudflare_zone_name
}

# Individual modules 

## Cloudflare zone settings and general security

module "cloudflare" {
  source = "./modules/cloudflare"

  zone_name = local.cloudflare_zone_name

}

## SSL Cert for load balancer

module "acm_ssl_cert" {
  source = "./modules/cloudflare-aws-ssl-cert"

  domain_name      = local.cloudflare_zone_name
  environment_name = local.environment_name

  tags = var.tags

}

## Load balancer

module "aws_lb" {
  source = "./modules/aws-lb"

  #allowed_ingress_ips = data.cloudflare_ip_ranges.cloudflare.ipv4_cidr_blocks
  vpc_id            = data.aws_vpc.default_vpc.id
  public_subnet_ids = data.aws_subnets.public_subnet_ids.ids

  ssl_cert_arn = module.acm_ssl_cert.acm_arn

  target_group_port = 5000

  environment_name = local.environment_name

  tags = var.tags

}

## ECS Task and Definition

module "aws_ecs" {
  source                = "./modules/aws-ecs"
  environment_name      = local.environment_name
  vpc_id                = data.aws_vpc.default_vpc.id
  alb_security_group_id = module.aws_lb.alb_security_group_id

  container_image     = "ghcr.io/karl-vanderslice/python-flask-web-app:latest"
  lb_target_group_arn = module.aws_lb.alb_target_group_arn
  ecs_subnets         = data.aws_subnets.public_subnet_ids.ids

  tags = var.tags

}

# Remaining non-module resources

## External CNAME record for Cloudflare, pointing at our application load balancer.  Not using a module here.

resource "cloudflare_record" "app_cname" {
  zone_id = data.cloudflare_zone.cloudflare.id
  name    = local.environment_name
  value   = module.aws_lb.alb_dns_record
  type    = "CNAME"
  proxied = true
  ttl     = 1
}
