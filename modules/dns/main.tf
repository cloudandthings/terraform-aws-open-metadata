data "aws_route53_zone" "openmetadata" {
  count = var.create ? 1 : 0

  name         = var.route53_zone_name
  private_zone = true
  vpc_id       = var.vpc_id
}

resource "aws_route53_record" "openmetadata_alb" {
  count = var.create && var.ingress_hostname != null ? 1 : 0

  zone_id = data.aws_route53_zone.openmetadata[0].zone_id
  name    = "${var.subdomain}.${data.aws_route53_zone.openmetadata[0].name}"
  type    = "CNAME"
  ttl     = 60
  records = [var.ingress_hostname]
}
