resource "aws_instance" "idc-singa_dns" {
  provider = aws.singa
  ami           = var.singa-ami
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  private_ip = "10.4.1.200"
  subnet_id = aws_subnet.idc-singa.id
  key_name = var.singakey
  security_groups = [aws_security_group.idc-singa.id]
  tags = {
    Name = "idc-singa_dns"
  }
  user_data = <<EOE
#!/bin/bash
hostnamectl set-hostname idc-singa-dns
ip route add 10.0.0.0/8 via 10.4.1.50
sed -i "s/^127.0.0.1   localhost/127.0.0.1 localhost idc-singa-dns/g" /etc/hosts
# Update and install necessary packages
yum update -y
yum install -y bind bind-utils glibc-langpack-ko
# Configure BIND
cat <<EOT > /etc/named.conf
options {
  directory "/var/named";
  recursion yes;
  allow-query { any; };
  forwarders {
        8.8.8.8;
  };
  forward only;
  auth-nxdomain no;
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
zone "idcsinga.internal" {
    type master;
    file "/var/named/db.idcsinga.internal";
};
zone "4.10.in-addr.arpa" {
    type master;
    file "/var/named/db.10.4";
};
EOT
# Create forward zone file
cat <<EOT > /var/named/db.idcsinga.internal
\$TTL 86400  ; 1 day
@ IN SOA idcsinga.internal. root.idcsinga.internal. (
    2025013001 ; serial
    3600       ; refresh
    900        ; retry
    604800     ; expire
    86400      ; minimum ttl
)
; DNS server
@      IN NS ns1.idcsinga.internal.
ns1    IN A  10.4.1.200
; Hosts
db     IN A  10.4.1.100
dns    IN A  10.4.1.200
cgw    IN A  10.4.1.50
EOT
# Create reverse zone file
cat <<EOT > /var/named/db.10.4
\$TTL 86400  ; 1 day
@ IN SOA idcsinga.internal. root.idcsinga.internal. (
    2025013002 ; serial
    3600       ; refresh
    900        ; retry
    604800     ; expire
    86400      ; minimum ttl
)
; DNS server
@      IN NS ns1.idcsinga.internal.
; PTR Records
100.1    IN PTR db.idcsinga.internal.  ; TTL 86400
200.1    IN PTR dns.idcsinga.internal. ; TTL 86400
50.1     IN PTR cgw.idcsinga.internal.  ; TTL 86400
EOT
# Set permissions and restart BIND
chown named:named /var/named/db.idcsinga.internal /var/named/db.10.4
chmod 640 /var/named/db.idcsinga.internal /var/named/db.10.4
systemctl enable named
systemctl start named
EOE
}
######################################################################
# resource "aws_instance" "idc-singa_db" {
#   provider = aws.singa
#   ami           = var.singa-ami
#   instance_type = "t2.micro"
#   associate_public_ip_address = "true"
#   private_ip = "10.2.1.100"
#   subnet_id = aws_subnet.idc-singa.id
#   security_groups = [aws_security_group.idc-singa.id]
#   tags = {
#     Name = "idc-singa_db"
#   }
#   user_data = <<EOF
# #!/bin/bash
# hostnamectl --static set-hostname singa-IDC-DB
# yum install -y mariadb-server mariadb lynx
# systemctl start mariadb && systemctl enable mariadb
# echo -e "\n\nqwe123\nqwe123\ny\ny\ny\ny\n" | /usr/bin/mysql_secure_installation
# mysql -uroot -pqwe123 -e "CREATE DATABASE sample; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY 'qwe123'; GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%' IDENTIFIED BY 'qwe123'; flush privileges;"
# mysql -uroot -pqwe123 -e "USE sample;CREATE TABLE EMPLOYEES (ID int(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,NAME VARCHAR(45),ADDRESS VARCHAR(90));"
# cat <<EOT> /etc/my.cnf
# [mysqld]
# datadir=/var/lib/mysql
# socket=/var/lib/mysql/mysql.sock
# symbolic-links=0           
# log-bin=mysql-bin
# server-id=1
# [mysqld_safe]
# log-error=/var/log/mariadb/mariadb.log
# pid-file=/var/run/mariadb/mariadb.pid
# !includedir /etc/my.cnf.d
# EOT
# systemctl restart mariadb
# cat <<EOT> /home/ec2-user/list.txt
# 10.1.3.100
# web1.awssinga.internal
# 10.1.4.100
# web2.awssinga.internal
# 10.2.1.100
# db.idcsinga.internal
# 10.2.1.200
# dns.idcsinga.internal
# 10.3.3.100
# websrv1.awssinga.internal
# 10.4.1.100
# db.idcsinga.internal
# 10.4.1.200
# dns.idcsinga.internal
# EOT
#  cat <<EOT> /home/ec2-user/pingall.sh
#!/bin/bash
# date
# cat list.txt |  while read output
# do
#     ping -c 1 -W 1 "$output" > /dev/null
#     if [ $? -eq 0 ]; then
#     echo "host $output is up"
#     else
#     echo "host $output is down"
#     fi
# done
# EOT
# chmod +x /home/ec2-user/pingall.sh
# EOF
# }
##################################################################

/* Error: Self-referential block
    on idc_singa/idc_singa_instance.tf line 66, in resource "aws_instance" "idc-singa_cgw":
    │   66:   leftid="${aws_instance.idc-singa_cgw.public_ip}"
    │
    │ Configuration for aws_instance.idc-singa_cgw may not refer to itself.
        문제점 : Instance가 생성되기 이전에 Public Ip를 참조하여 UserData에 사용하려고 함.
        해결방안 : ENI, EIP를 생성하여 UserData에 사용하도록 함. */
        
####### singa_vpn.tf로 이동
# resource "aws_network_interface" "idc-singa_cgw_eni" {
#   provider          = aws.singa
#   subnet_id         = aws_subnet.idc-singa.id
#   private_ips       = ["10.4.1.50"]
#   security_groups   = [aws_security_group.idc-singa.id]
#   source_dest_check = false
#   tags = {
#     Name = "idc-singa_cgw_eni"
#   }
# }
# resource "aws_eip" "idc-singa_cgw_eip" { 
#     provider = aws.singa
#     network_interface = aws_network_interface.idc-singa_cgw_eni.id
# } 
# resource "aws_instance" "idc-singa_cgw" {
#   provider = aws.singa
#   ami           = var.singa-ami
#   instance_type = "t2.micro"
#   key_name = var.singakey
#   network_interface {
#     network_interface_id = aws_network_interface.idc-singa_cgw_eni.id
#     device_index = 0
#   }
#   tags = {
#     Name = "idc-singa_cgw"
#   }
#   user_data = <<EOE
# #!/bin/bash
# yum -y install tcpdump openswan
# cat <<EOF>> /etc/sysctl.conf
# net.ipv4.ip_forward=1
# net.ipv4.conf.all.accept_redirects = 0
# net.ipv4.conf.all.send_redirects = 0
# net.ipv4.conf.default.send_redirects = 0
# net.ipv4.conf.eth0.send_redirects = 0
# net.ipv4.conf.default.accept_redirects = 0
# net.ipv4.conf.eth0.accept_redirects = 0
# net.ipv4.conf.ip_vti0.rp_filter = 0
# net.ipv4.conf.eth0.rp_filter = 0
# net.ipv4.conf.default.rp_filter = 0
# net.ipv4.conf.all.rp_filter = 0
# EOF
# sysctl -p /etc/sysctl.conf
# cat <<EOF> /etc/ipsec.d/aws.conf
# conn Tunnel1
#   authby=secret
#   auto=start
#   left=%defaultroute
#   leftid=${aws_eip.idc-singa_cgw_eip.public_ip}
#   right=${aws_vpn_connection.idc-singa.tunnel1_address}
#   type=tunnel
#   ikelifetime=8h
#   keylife=1h
#   phase2alg=aes128-sha1;modp1024
#   ike=aes128-sha1;modp1024
#   keyingtries=%forever
#   keyexchange=ike
#   leftsubnet=10.4.0.0/16
#   rightsubnet=10.3.0.0/16
#   dpddelay=10
#   dpdtimeout=30
#   dpdaction=restart_by_peer
# EOF
# cat <<EOF> /etc/ipsec.d/aws.secrets
# ${aws_eip.idc-singa_cgw_eip.public_ip} ${aws_vpn_connection.idc-singa.tunnel1_address} : PSK "timangs"
# EOF
# systemctl start ipsec
# systemctl enable ipsec
# hostnamectl --static set-hostname IDC-CGW
# EOE
# }