resource "aws_acm_certificate" "cert" {
  domain_name               = local.redirect_to_subdomain ? var.source_subdomain : var.zone
  subject_alternative_names = local.redirect_to_subdomain ? [] : ["www.${var.zone}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
