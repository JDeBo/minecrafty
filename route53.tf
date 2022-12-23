resource "aws_route53_zone" "sbx" {
  name = "sbx.justindebo.com"
}

resource "aws_route53_record" "example" {
  name            = "crafty.sbx.justindebo.com"
  ttl             = 172800
  type            = "A"
  zone_id         = aws_route53_zone.sbx.zone_id

  records = [
    aws_eip.this.public_ip
  ]
}