
resource "aws_instance" "ise_db_instance" {
  provider = aws.se
  ami           = var.se_ami
  instance_type = var.instance_type
  private_ip = "10.2.1.100"
  key_name = var.se_key
  subnet_id = aws_subnet.ise_subnet["isn1"].id
  associate_public_ip_address = true
  security_groups = [aws_security_group.ise_securitygroup.id]
  source_dest_check = false
  tags = {
    Name = "ise_dbinstance"
  }
  user_data = <<EOA
#!/bin/bash
hostnamectl --static set-hostname IDC-seoul-DB
yum install -y mariadb-server mariadb lynx
systemctl start mariadb && systemctl enable mariadb

cat <<EOF > /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0
collation-server = utf8mb4_unicode_ci
init-connect='SET NAMES utf8'
character-set-server=utf8mb4
server-id=1
log-bin= /var/lib/mysql/binlog
binlog-format=ROW

[client]
default-character-set=utf8mb4

[mysql]
default-character-set=utf8mb4

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid

!includedir /etc/my.cnf.d
EOF

systemctl restart mariadb

echo -e "\n\nqwe123\nqwe123\ny\ny\ny\ny\n" | /usr/bin/mysql_secure_installation
mysql -uroot -pqwe123 -e "CREATE USER 'user1'@'%' identified by 'p@ssw0rd';"
mysql -uroot -pqwe123 -e "GRANT all privileges ON *.* TO user1@'%' with grant option;"
mysql -uroot -pqwe123 -e "CREATE DATABASE sqlDB; GRANT ALL PRIVILEGES ON *.* TO 'user1'@'%' IDENTIFIED BY 'qwe123'; GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%' IDENTIFIED BY 'qwe123'; flush privileges;"
mysql -uroot -pqwe123 -e "GRANT SELECT ON sqlDB.* TO 'repl_user'@'%' IDENTIFIED BY 'qwe123';FLUSH PRIVILEGES;"
mysql -uroot -pqwe123 -e "USE sqlDB;CREATE TABLE userTBL( userID CHAR(8) NOT NULL PRIMARY KEY, name NVARCHAR(50) NOT NULL, mobile CHAR(11) NOT NULL, birthYear CHAR(10), email VARCHAR(30), mDATE DATE);"
cat << EOF > data.sql
USE sqlDB;
INSERT INTO userTBL(userID, name, mobile, birthYear, email, mDATE) 
VALUES('assd', '감자탕', '01011112222', '1990512', NULL, '2012-4-4');
INSERT INTO userTBL(userID, name, mobile, birthYear, email, mDATE) 
VALUES('rwsq', '해장국', '01033334444', '1950', 'sss@email.com', '2009-4-4');
INSERT INTO userTBL(userID, name, mobile, birthYear, email, mDATE)
VALUES('gsdf', '김치국','01033331111', '1979', NULL, '2013-12-12');
INSERT INTO userTBL(userID, name, mobile, birthYear, email, mDATE)
VALUES('rdfsgmk', '돈가스', '01031212222', '1963', NULL, '2009-9-9');
INSERT INTO userTBL(userID, name, mobile, birthYear, email, mDATE)
VALUES('gadsmkl', '오징어', '01033332222', '1963', 'jiho22@email.com','2009-9-9');
EOF
mysql -uroot -pqwe123 < data.sql

mysql -uroot -pqwe123 -e "SHOW MASTER STATUS\G" | grep File | awk '{print $2}' > File.txt
mysql -uroot -pqwe123 -e "SHOW MASTER STATUS\G" | grep Position | awk '{print $2}' > Position.txt

cat <<EOF> /home/ec2-user/list.txt
10.1.3.100
websrv1.awsseoul.internal
10.1.4.100
websrv2.awsseoul.internal
10.2.1.100
db.idcseoul.internal
10.2.1.200
dns.idcseoul.internal
10.3.3.100
websrv1.awssinga.internal
10.4.1.100
db.idcsinga.internal
10.4.1.200
dns.idcsinga.internal
EOF
curl -o /home/ec2-user/pingall.sh https://cloudneta-book.s3.ap-northeast-2.amazonaws.com/chapter6/pingall.sh --silent
chmod +x /home/ec2-user/pingall.sh
sudo systemctl restart mariadb
mysqldump -uroot -pqwe123 --all-databases --lock-all-tables --events > /home/ec2-user/mysql_dump.sql
mysql -uroot -pqwe123 -e "unlock tables;"
scp mysql_dump.sql root@db.idcsinga.internal:/home/ec2-user/
scp File.txt root@db.idcsinga.internal:/home/ec2-user/
scp Position.txt root@db.idcsinga.internal:/home/ec2-user/
EOA
}
