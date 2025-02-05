
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
  depends_on = [ aws_instance.ise_db_instance ]
  user_data = <<EOA
#!/bin/bash
sleep 200
(
echo "qwe123"
echo "qwe123"
) | passwd --stdin root
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config
service sshd restart
hostnamectl --static set-hostname IDC-singa-DB
yum install -y mariadb-server mariadb lynx
systemctl start mariadb && systemctl enable mariadb
echo -e "\n\nqwe123\nqwe123\ny\ny\ny\ny\n" | /usr/bin/mysql_secure_installation
mysql -uroot -pqwe123 -e "GRANT ALL PRIVILEGES ON *.* TO 'repl_user'@'%' IDENTIFIED BY 'qwe123';FLUSH PRIVILEGES;"

cat <<EOF > /etc/my.cnf
[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
symbolic-links=0
collation-server = utf8mb4_unicode_ci
init-connect='SET NAMES utf8'
character-set-server=utf8mb4
server-id=2
read_only=1
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
mysql -uroot -pqwe123 < mysql_dump.sql
CHANGE MASTER TO MASTER_HOST='db.idcseoul.internal',MASTER_USER='repl_user',MASTER_PASSWORD='qwe123',MASTER_LOG_FILE='binlog.000002',MASTER_LOG_POS=316;
MASTER_LOG_FILE=$(cat /home/ec2-user/File.txt)
MASTER_LOG_POS=$(cat /home/ec2-user/Position.txt)
mysql -uroot -pqwe123 -e "CHANGE MASTER TO MASTER_HOST='db.idcseoul.internal', MASTER_USER='repl_user', MASTER_PASSWORD='qwe123', MASTER_LOG_FILE='$MASTER_LOG_FILE', MASTER_LOG_POS=$MASTER_LOG_POS;"
mysql -uroot -pqwe123 -e "start slave;"
EOA
}
