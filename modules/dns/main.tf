resource "aws_route53_record" "sub_cname" {
  zone_id = var.hosted_zone_id
  name    = "${var.subdomain}.${var.hosted_zone_name}"
  type    = "CNAME"
  ttl     = 60
  records = [var.eb_cname]
}
