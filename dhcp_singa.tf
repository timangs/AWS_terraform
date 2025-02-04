resource "aws_vpc_dhcp_options" "asi_dhcp" {
  provider = aws.si
  domain_name_servers = ["10.3.3.250","10.3.4.250"]
    tags = {
        Name = "asi_dhcp"
    }
}
resource "aws_vpc_dhcp_options_association" "asi_dhcp_assocation" {
  provider = aws.si
  vpc_id          = aws_vpc.asi_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.asi_dhcp.id
}
