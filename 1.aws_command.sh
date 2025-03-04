# Instances List
aws ec2 describe-instances --query "Reservations[*].Instances[*].{InstanceId:InstanceId,PublicIp:PublicIpAddress,PrivateIp:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value}"

# Instance Connect
aws ec2-instance-connect ssh --private-key-file seoul-key --instance-id i-xxxxxxxxxxxxxxxxx

# efs 연결
sudo mount -t efs -o tls fs-0dxxxxxxx0:/ /seoul
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 10.0.1.81:/ efs