resource "aws_route53_zone" "ase_zone" {
  provider = aws.se
  name = "awsseoul.internal"
  vpc {
    vpc_id = aws_vpc.ase_vpc.id
    }  
}
resource "aws_route53_record" "ase_web1_record" {
  provider = aws.se
  zone_id = aws_route53_zone.ase_zone.zone_id
  name    = "web1.awsseoul.internal"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.ase_instance_web1.private_ip]
}
resource "aws_route53_record" "ase_web2_record" {
  provider = aws.se
  zone_id = aws_route53_zone.ase_zone.zone_id
  name    = "web2.awsseoul.internal"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.ase_instance_web2.private_ip]
}