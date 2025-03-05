resource "aws_vpc_dhcp_options" "ise_dhcp" {
  provider = aws.se
  domain_name_servers = ["10.2.1.200","8.8.8.8"]
    tags = {
        Name = "ise_dhcp"
    }
}
resource "aws_vpc_dhcp_options_association" "ise_dhcp_assocation" {
  provider = aws.se
  vpc_id          = aws_vpc.ise_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.ise_dhcp.id
}
