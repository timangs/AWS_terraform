
resource "aws_vpc_dhcp_options" "idc_seoul" {
  provider = aws.seoul
  domain_name_servers = ["10.2.1.200","8.8.8.8"]
  domain_name = "idcseoul.internal"
    tags = {
        Name = "idc-seoul-dns-resolver"
    }
}
resource "aws_vpc_dhcp_options_association" "idc_seoul" {
  provider = aws.seoul
  vpc_id          = aws_vpc.idc-seoul.id
  dhcp_options_id = aws_vpc_dhcp_options.idc_seoul.id
  depends_on = [ aws_vpc.idc-seoul,
                 aws_vpc_dhcp_options.idc_seoul ]
}

resource "aws_instance" "idc-seoul_dns" {
  provider = aws.seoul
  ami           = var.seoul-ami
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  private_ip = "10.2.1.200"
  subnet_id = aws_subnet.idc-seoul.id
  source_dest_check = false
  key_name = var.seoulkey
  security_groups = [aws_security_group.idc-seoul.id]
  tags = {
    Name = "idc-seoul_dns"
  }
  user_data = <<EOE
#!/bin/bash
echo "toor" | passwd --stdin root
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/^PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl restart sshd
sed -i "s/^127.0.0.1   localhost/127.0.0.1 localhost idc-seoul-dns/g" /etc/hosts
# Update and install necessary packages
yum update -y
yum install -y bind bind-utils glibc-langpack-ko
# Configure BIND
cp -p /etc/named.conf /etc/named.conf.bak
cat <<EOT > /etc/named.conf
options {
        listen-on port 53 { any; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";        
        recursing-file  "/var/named/data/named.recursing";
        secroots-file   "/var/named/data/named.secroots";
        allow-query     { any; };
        recursion yes;
        dnssec-enable no;
        dnssec-validation no;
        bindkeys-file "/etc/named.root.key";
        managed-keys-directory "/var/named/dynamic";
        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
zone "." IN {
        type hint;
        file "named.ca";
};
zone "awsseoul.internal" {
    type forward;
    forward only;
    forwarders { 10.1.3.250; 10.1.4.250; };
};
zone "awssinga.internal" {
    type forward;
    forward only;
    forwarders { 10.3.3.250; 10.3.4.250; };
};
zone "idcseoul.internal" {
    type master;
    file "/var/named/db.idcseoul.internal";
};
zone "2.10.in-addr.arpa" {
    type master;
    file "/var/named/db.10.2";
};
include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOT
# Create forward zone file
cat <<EOT > /var/named/db.idcseoul.internal
\$TTL 86400  ; 1 day
@ IN SOA idcseoul.internal. root.idcseoul.internal. (
    2025013001 ; serial
    3600       ; refresh
    900        ; retry
    604800     ; expire
    86400      ; minimum ttl
)
; DNS server
@      IN NS ns1.idcseoul.internal.
ns1    IN A  10.2.1.200
; Hosts
db     IN A  10.2.1.100
dns    IN A  10.2.1.200
EOT
# Create reverse zone file
cat <<EOT > /var/named/db.10.2
\$TTL 86400  ; 1 day
@ IN SOA idcseoul.internal. root.idcseoul.internal. (
    2025013002 ; serial
    3600       ; refresh
    900        ; retry
    604800     ; expire
    86400      ; minimum ttl
)
; DNS server
@      IN NS ns1.idcseoul.internal.
; PTR Records
100.1    IN PTR db.idcseoul.internal.  ; TTL 86400
200.1    IN PTR dns.idcseoul.internal. ; TTL 86400
EOT
# Set permissions and restart BIND
chown named:named /var/named/db.idcseoul.internal /var/named/db.10.2
chmod 640 /var/named/db.idcseoul.internal /var/named/db.10.2
systemctl enable named
systemctl start named
EOE
}