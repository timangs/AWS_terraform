resource "aws_vpc_dhcp_options" "isi_dhcp" {
  provider = aws.si
  domain_name_servers = ["10.4.1.200","8.8.8.8"]
    tags = {
        Name = "isi_dhcp"
    }
}
resource "aws_vpc_dhcp_options_association" "isi_dhcp_assocation" {
  provider = aws.si
  vpc_id          = aws_vpc.isi_vpc.id
  dhcp_options_id = aws_vpc_dhcp_options.isi_dhcp.id
}
