# Instances List
aws ec2 describe-instances --query "Reservations[*].Instances[*].{InstanceId:InstanceId,PublicIp:PublicIpAddress,PrivateIp:PrivateIpAddress,Name:Tags[?Key=='Name']|[0].Value}"

# Instance Connect
aws ec2-instance-connect ssh --private-key-file soldesk-key --region ap-northeast-2 --instance-id i-xxxxxxxxxxxxxxxxx

