# securitygroup.tf

resource "aws_security_group" "kops_ec2_sg" {
  name        = "kops-ec2-sg"
  description = "kops ec2 Security Group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.sg_ingress_ssh_cidr]
  }

  ingress {
    description = "HTTP access (if needed for testing)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere as per CFN (Consider restricting this)
  }

  # Egress rule to allow all outbound traffic (common default)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.instance_tags, {
    Name = "KOPS-EC2-SG"
  })
}
