
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
CREATE DATABASE sqlDB ;
USE sqlDB;
CREATE TABLE userTBL
( 
userID CHAR(8) NOT NULL PRIMARY KEY,
name NVARCHAR(10) NOT NULL,
birthYear INT NOT NULL,
addr NCHAR(2) NOT NULL,
mobile1 CHAR(3),
mobile2 CHAR(8),
height SMALLINT,
mDate DATE
);

INSERT INTO userTBL VALUES ('LSG', '이승기', 1987, '서울', '011', '1111111', 182, '2008-8-8');
INSERT INTO userTBL VALUES ('KBS', '김범수', 1979, '경남', '011', '2222222', 173, '2012-4-4');
INSERT INTO userTBL VALUES ('KKH', '김경호', 1971, '전남', '019', '3333333', 177, '2007-7-7');
INSERT INTO userTBL VALUES ('JYP', '조용필', 1950, '경기', '011', '4444444', 166, '2009-4-4');
INSERT INTO userTBL VALUES ('SSK', '성시경', 1979, '서울', NULL, NULL, 186, '2013-12-12');
INSERT INTO userTBL VALUES ('LJB', '임재범', 1963, '서울', '016', '6666666', 182, '2009-9-9');
INSERT INTO userTBL VALUES ('YJS', '윤종신', 1969, '경남', NULL, NULL, 170, '2005-5-5');
INSERT INTO userTBL VALUES ('EJW', '은지원', 1972, '경북', '011', '8888888', 174, '2014-3-3');
INSERT INTO userTBL VALUES ('JKW', '조관우', 1965, '경기', '018', '9999999', 172, '2010-10-10');
INSERT INTO userTBL VALUES ('BBK', '바비킴', 1973, '서울', '010', '0000000', 176, '2013-5-5');
INSERT INTO userTBL VALUES ('JUL', '김주일', 1978, '서울', '010', '0000000', 176, '2013-5-5');


flush privileges;

CREATE TABLE buyTBL
( 
num int auto_increment not null primary key,
userID char(8) not null,
prodName char(6) not null,
groupName char(4),
price int not null,
amount smallint not null,
foreign key (userID) references userTBL(userID)
);

INSERT INTO buyTBL VALUES (NULL, 'KBS', '운동화', NULL, 30, 2);
INSERT INTO buyTBL VALUES (NULL, 'KBS', '노트북', '전자', 1000, 1);
INSERT INTO buyTBL VALUES (NULL, 'JYP', '모니터', '전자', 200, 1);
INSERT INTO buyTBL VALUES (NULL, 'BBK', '모니터', '전자', 200, 5);
INSERT INTO buyTBL VALUES (NULL, 'KBS', '청바지', '의류', 50, 3);
INSERT INTO buyTBL VALUES (NULL, 'BBK', '메모리', '전자', 80, 10);
INSERT INTO buyTBL VALUES (NULL, 'SSK', '책', '서적', 15, 5);
INSERT INTO buyTBL VALUES (NULL, 'EJW', '책', '서적', 15, 2);
INSERT INTO buyTBL VALUES (NULL, 'EJW', '청바지', '의류', 50, 1);
INSERT INTO buyTBL VALUES (NULL, 'BBK', '운동화', NULL, 30, 2);
INSERT INTO buyTBL VALUES (NULL, 'EJW', '책', '서적', 15, 1);
INSERT INTO buyTBL VALUES (NULL, 'BBK', '운동화', NULL, 30, 2);
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
