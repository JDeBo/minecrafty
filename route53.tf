# import {
#   to = aws_route53_zone.sbx
#   id = "Z0435551M62O980YNFJ9"  # Replace with actual zone ID
# }

# import {
#   to = aws_route53_record.example
#   id = "Z0435551M62O980YNFJ9_crafty.sbx.justindebo.com_A" # Replace with zone ID_record name_record type
# }

resource "aws_route53_zone" "sbx" {
  name = "sbx.justindebo.com"
}

resource "aws_route53_record" "example" {
  name            = "crafty.sbx.justindebo.com"
  ttl             = 172800
  type            = "A"
  zone_id         = aws_route53_zone.sbx.zone_id

  records = [
    aws_eip.spot.public_ip
  ]
}
