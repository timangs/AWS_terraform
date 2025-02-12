# EFS 실습 구성

![image](https://github.com/user-attachments/assets/c5e64ba1-a269-4ae1-a995-429e2c66ecd4)

----

해당 환경에서 테스트할 VPC 10.1.0.0/16을 추가해서 VPC Peering 구성

![image](https://github.com/user-attachments/assets/52147005-1a73-4b76-94da-8c5d7e9bf19a)

----

Inter-VPC EFS연결

https://github.com/aws/efs-utils/blob/master/README.md#install-botocore

```
yum install -y amazon-efs-utils
mkdir /soldesk
yum -y install wget
if [[ "$(python3 -V 2>&1)" =~ ^(Python 3.6.*) ]]; then
    wget https://bootstrap.pypa.io/pip/3.6/get-pip.py -O /tmp/get-pip.py
elif [[ "$(python3 -V 2>&1)" =~ ^(Python 3.5.*) ]]; then
    wget https://bootstrap.pypa.io/pip/3.5/get-pip.py -O /tmp/get-pip.py
elif [[ "$(python3 -V 2>&1)" =~ ^(Python 3.4.*) ]]; then
    wget https://bootstrap.pypa.io/pip/3.4/get-pip.py -O /tmp/get-pip.py
elif [[ "$(python3 -V 2>&1)" =~ ^(Python 3.7.*) ]]; then
    wget https://bootstrap.pypa.io/pip/3.7/get-pip.py -O /tmp/get-pip.py
else
    wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
fi
python3 /tmp/get-pip.py
pip3 install botocore || /usr/local/bin/pip3 install botocore
pip3 install botocore --upgrade
mount -t efs -o tls ${aws_efs_file_system.idc_efs.id}:/ /soldesk
```