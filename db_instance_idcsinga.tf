
resource "aws_instance" "isi_db_instance" {
  provider = aws.si
  ami           = var.si_ami
  instance_type = var.instance_type
  private_ip = "10.4.1.100"
  key_name = var.si_key
  subnet_id = aws_subnet.isi_subnet["isn1"].id
  associate_public_ip_address = true
  security_groups = [aws_security_group.isi_securitygroup.id]
  source_dest_check = false
  tags = {
    Name = "isi_dbinstance"
  }
  user_data = <<EOF
#!/bin/bash

yum install -y mariadb-server mariadb lynx
sleep 10
systemctl start mariadb
sleep 10
systemctl enable mariadb
echo -e "\n\nqwe123\nqwe123\ny\ny\ny\ny\n" | /usr/bin/mysql_secure_installation
mysql -uroot -pqwe123 -e "CREATE DATABASE sample; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY 'qwe123'; GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%' IDENTIFIED BY 'qwe123'; flush privileges;"
mysql -uroot -pqwe123 -e "USE sample;CREATE TABLE EMPLOYEES (ID int(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,NAME VARCHAR(45),ADDRESS VARCHAR(90));"
cat <<EOT> /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0           
log-bin=mysql-bin
server-id=1
[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid
!includedir /etc/my.cnf.d
EOT
systemctl restart mariadb
cat <<EOT> /home/ec2-user/list.txt
10.1.3.100
web1.awsseoul.internal
10.1.4.100
web2.awsseoul.internal
10.2.1.100
db.idcseoul.internal
10.2.1.200
dns.idcseoul.internal
10.3.3.100
web1.awssp.internal
10.4.1.100
db.idcsp.internal
10.4.1.200
dns.idcsp.internal
EOT
curl -o /home/ec2-user/pingall.sh https://cloudneta-book.s3.ap-northeast-2.amazonaws.com/chapter6/pingall.sh --silent
chmod +x /home/ec2-user/pingall.sh
EOF
}
