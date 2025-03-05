resource "aws_route53_zone" "asi_zone" {
  provider = aws.si
  name = "awssinga.internal"
  vpc {
    vpc_id = aws_vpc.asi_vpc.id
  }  
}

resource "aws_route53_record" "asi_web1_record" {
  provider = aws.si
  zone_id = aws_route53_zone.asi_zone.zone_id
  name    = "web1.awssinga.internal"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.asi_instance_web1.private_ip]
}
