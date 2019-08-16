data "aws_route53_zone" "default" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "jenkins" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "jenkins.${data.aws_route53_zone.default.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.nginx.public_ip]
}

resource "aws_route53_record" "sonar" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "sonar.${data.aws_route53_zone.default.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.nginx.public_ip]
}

resource "aws_route53_record" "nexus" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "nexus.${data.aws_route53_zone.default.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.nginx.public_ip]
}

resource "aws_route53_record" "gitlab" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "gitlab.${data.aws_route53_zone.default.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.nginx.public_ip]
}

resource "aws_route53_record" "jira" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "jira.${data.aws_route53_zone.default.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.nginx.public_ip]
}

resource "aws_route53_record" "confluence" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "confluence.${data.aws_route53_zone.default.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.nginx.public_ip]
}

resource "aws_route53_record" "monitor" {
  zone_id = data.aws_route53_zone.default.zone_id
  name    = "monitor.${data.aws_route53_zone.default.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.nginx.public_ip]
}

resource "aws_route53_record" "monitor" {
  zone_id = data.aws_route53_zone.akawork.zone_id
  name    = "monitor.${data.aws_route53_zone.akawork.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.nginx.public_ip]
}
