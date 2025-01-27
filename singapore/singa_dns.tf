resource "aws_route53_zone" "singa" {
  provider = aws.singa
  name = "awssinga.internal"
  vpc {vpc_id = aws_vpc.singa.id}  
}
resource "aws_route53_record" "singa_web1" {
  provider = aws.singa
  zone_id = aws_route53_zone.singa.zone_id
  name    = "web1.awssinga.internal"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.singa_pri1.private_ip]
}