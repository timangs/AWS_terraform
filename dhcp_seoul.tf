resource "aws_vpc_dhcp_options" "ase_dhcp" {
  provider = aws.se
  domain_name_servers = ["10.1.1.250","10.1.2.250"]
    tags = {
        Name = "ase_dhcp"
    }
}
resource "aws_vpc_dhcp_options_association" "ase_dhcp_assocation" {
  provider = aws.se
  vpc_id          = aws_vpc.ase_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.ase_dhcp.id
}
