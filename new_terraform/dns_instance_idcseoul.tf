resource "aws_instance" "ise_dns_instance" {
  provider      = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  private_ip    = "10.2.1.200"
  key_name      = var.se_key
  associate_public_ip_address = true
  subnet_id     = aws_subnet.ise_subnet["isn1"].id
  security_groups = [aws_security_group.ise_securitygroup.id]
  source_dest_check = false
  tags = {
    Name = "ise_dns_instance"
  }
  depends_on = [ aws_internet_gateway.ise_igw ]
  user_data = <<EOF
#!/bin/bash

sed -i "s/^127.0.0.1   localhost/127.0.0.1 localhost idc-seoul-dns/g" /etc/hosts
# Update and install necessary packages

yum clean all
rm -rf /var/cache/yum
yum update -y
yum install -y bind bind-utils glibc-langpack-ko

sed -i 's/listen-on port 53 { 127.0.0.1; };/listen-on port 53 { any; };/g' /etc/named.conf
sed -i 's/{ localhost; };/{ any; };/g' /etc/named.conf
sed -i 's/dnssec-validation yes;/dnssec-validation no;/g' /etc/named.conf
sed -i 's/dnssec-enable yes;/dnssec-enable no;/g' /etc/named.conf

cat <<EOT >> /etc/named.rfc1912.zones
zone "idcseoul.internal" {
    type master;
    file "/var/named/idcseoul.internal.zone";
};

zone "awsseoul.internal" {
    type forward;
    forwarders { 10.1.3.250; 10.1.4.250; };
};

zone "awssp.internal" {
    type forward;
    forwarders { 10.3.3.250; 10.3.4.250; };
};

zone "idcsp.internal" {
    type forward;
    forwarders { 10.4.1.200; };
};
EOT

cat <<EOT > /var/named/idcseoul.internal.zone
\$TTL 86400
@   IN  SOA     ns.idcseoul.internal. admin.idcseoul.internal. (
        2025010801 ; Serial
        3600       ; Refresh
        1800       ; Retry
        1209600    ; Expire
        86400 )    ; Minimum TTL
@       IN  NS      ns.idcseoul.internal.
ns      IN  A       10.2.1.200
dns     IN  A       10.2.1.200
db      IN  A       10.2.1.100
EOT

chown root:named /etc/named.conf /var/named/idcseoul.internal.zone
chmod 640 /etc/named.conf
chmod 640 /var/named/idcseoul.internal.zone

systemctl enable named
systemctl start named
EOF
}