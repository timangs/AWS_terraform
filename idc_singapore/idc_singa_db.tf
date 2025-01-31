resource "aws_instance" "idc-singa_db" {
  provider = aws.singa
  ami           = var.singa-ami
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  private_ip = "10.4.1.100"
  subnet_id = aws_subnet.idc-singa.id
  key_name = var.singakey
  security_groups = [aws_security_group.idc-singa.id]
  tags = {
    Name = "idc-singa_db"
  }
  user_data = <<EOE
#!/bin/bash
ip route add 10.0.0.0/8 via 10.4.1.50
hostnamectl --static set-hostname singa-db
yum install -y mariadb-server mariadb lynx
systemctl start mariadb && systemctl enable mariadb
echo -e "\n\nqwe123\nqwe123\ny\ny\ny\ny\n" | /usr/bin/mysql_secure_installation
# mysql -uroot -pqwe123 -e "CREATE DATABASE sample; GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY 'qwe123'; GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'%' IDENTIFIED BY 'qwe123'; flush privileges;"
# mysql -uroot -pqwe123 -e "USE sample;CREATE TABLE EMPLOYEES (ID int(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,NAME VARCHAR(45),ADDRESS VARCHAR(90));"
echo '[client]' > ~/.my.cnf
echo 'user=root' >> ~/.my.cnf
echo 'password=qwe123' >> ~/.my.cnf
chmod 600 ~/.my.cnf
# mysqldump --defaults-extra-file=/root/.my.cnf --all-databases --lock-all-tables --events > /home/ec2-user/mysql_dump.sql
# curl -o /home/ec2-user/userTbl_Query.sql https://raw.githubusercontent.com/timangs/initial_configuration_terraform/main/web_sample/userTbl_Query.sql
# mysql -uroot -pqwe123 < /home/ec2-user/userTbl_Query.sql
sudo amazon-linux-extras install epel -y
sudo yum install sshpass -y
# mysqldump --defaults-extra-file=/root/.my.cnf --all-databases --lock-all-tables --events > /home/ec2-user/mysql_dump.sql
# sshpass -p 'toor' scp -o StrictHostKeyChecking=no mysql_dump.sql root@10.2.1.200:/root/my.sql
cat <<EOD> /etc/my.cnf.d/server.cnf
[mysqld]
collation-server = utf8_unicode_ci
init-connect='SET NAMES utf8'
character-set-server=utf8
#validate_password.policy=LOW
#default_authentication_plugin=mysql_native_password
log-bin=mysql-bin
server_id=2
read_only=1
EOD
sleep 10
mysql -u root -p < /root/seoul.sql
# ls -l /var/lib/mysql/ | awk '{print $9}' | grep -i bin.0 >> /home/ec2-user/binlist
mysql -uroot -pqwe123 -e "change master to master_host='192.168.111.100',master_user='slave', master_password='toor',master_log_file='mysql-bin.000001',master_log_pos=778;"
mysql -uroot -pqwe123 -e "START SLAVE;"
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
systemctl restart mariadb
cat <<EOT> /home/ec2-user/list.txt
10.1.3.100
10.1.4.100
10.2.1.100
10.2.1.200
10.3.3.100
10.4.1.100
10.4.1.200
10.4.1.50
web1.awsseoul.internal
web2.awsseoul.internal
db.idcseoul.internal
dns.idcseoul.internal
web1.awssinga.internal
db.idcsinga.internal
dns.idcsinga.internal
cgw.idcsinga.internal
EOT
cat << EOF > /home/ec2-user/pingall.sh
#!/bin/bash
date
cat /home/ec2-user/list.txt |  while read output
do
    if [ `echo \$output | grep "10" | wc -l` -eq 0 ]; then
        nslookup \$output >/dev/null 2>/dev/null
        if [ \$? -eq 0 ]; then
            echo "[  UP domain] \$output"
        else
            echo "[DOWN domain] \$output"
        fi
    else
        ping -c 1 -w 1 "\$output" > /dev/null 2>/dev/null
        if [ \$? -eq 0 ]; then
            echo "[  UP host  ] \$output"
        else
            echo "[DOWN host  ] \$output"
        fi
    fi
done
EOF
chmod +x /home/ec2-user/pingall.sh
EOE
  }