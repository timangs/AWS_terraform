resource "aws_route53_zone" "seoul" {
  provider = aws.seoul
  name = "awsseoul.internal"
  vpc {vpc_id = aws_vpc.seoul.id}  
}
resource "aws_route53_record" "seoul_web1" {
  provider = aws.seoul
  zone_id = aws_route53_zone.seoul.zone_id
  name    = "web1.awsseoul.internal"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.seoul_pri1.private_ip]
}
resource "aws_route53_record" "seoul_web2" {
  provider = aws.seoul
  zone_id = aws_route53_zone.seoul.zone_id
  name    = "web2.awsseoul.internal"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.seoul_pri2.private_ip]
}