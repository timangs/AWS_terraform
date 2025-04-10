# 생성될 구성의 기본 형태

클라우드의 확장성, 유연성, 비용 효율성 등 다양한 장점을 제공하여 기업의 클라우드 전환은 앞으로도 계속될 것으로 생각됩니다.

그러나 기존 온프레미스 환경으로 구성되어 전환에 높은 초기 도입 비용으로 현실적인 제약이 있을 수 있기에

이번 목표로 한 형태에서는 온프레미스 환경과 클라우드가 Customer Gateway를 통한 VPN을 생성하여 통신하는 모습으로 구현했습니다.

![image](https://github.com/user-attachments/assets/301f9b1a-c155-4ca7-83e2-563031effe78)

<!-- 목차만들거임
[1. 사용 권한 설정](##terraform-user-권한-설정)

[2. VPN](###-VPN)

[3. NAT](###-NAT)

[4. ELB](###-ELB)

[5. GA](###-GA\(Global-Acc)

[6. Inter-region](###-inter-region)

[7. DNS](###-DNS)
-->

## 사용된 Terraform User 권한 설정

----

![image](https://github.com/user-attachments/assets/4fc5def1-6db5-44bb-89a6-b03cf2904593)

----

# 필요 구현사항

### Prerequisite
```
resource "aws_vpc" "ase_vpc" { ... }
# VPC의 생성

resource "aws_subnet" "ase_subnet" { ... }
# 서브넷 생성

resource "aws_route_table" "ase_routetable" { ... }
# 라우팅 테이블 생성

resource "aws_route_table_association" "ase_routetable_association" { ... }
# 서브넷과 라우팅 테이블 연결

# vpc_*.tf 내용을 확인하여 자세한 내용 확인 가능
```

### 1. Internet Gateway

AWS에서는 Instace가 인터넷 통신이 되기 위해서는 3가지 조건이 필요합니다.

> 1. Instance의 Public Ip 부여
```
resource "aws_instance" "ase_instance_nat1" {
  ...
  associate_public_ip_address = true #이 부분이 True로 설정되어야 Public Ip를 부여받음
  ...
}
```

> 2. Internet gateway 생성
```
resource "aws_internet_gateway" "ase_igw" {
    provider = aws.se
  vpc_id = aws_vpc.ase_vpc.id
  tags = {
    Name = "ase_igw"
  }
}
```

> 3. Internet gateway route 설정

```
resource "aws_route" "ase_igw_route" {
    provider = aws.se
    route_table_id            = aws_route_table.ase_routetable["apub1"].id
    destination_cidr_block    = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ase_igw.id
}
```

해당 내용에서는 전체(0.0.0.0/0)에 대해서 Internet gateway에 연결했지만 범위를 지정할 수 있습니다.

----

### 2. NAT (Network Address Translation)

NAT Gateway는 Private Subnet의 인스턴스가 인터넷에 연결할 수 있도록 아웃바운드 트래픽을 허용하는 서비스입니다.

![image](https://github.com/user-attachments/assets/04f39d39-dc6f-42c8-a27d-bd9132991dda)

VPC NAT Gateway를 활용할 수 있지만, 이번 프로젝트에서는 인스턴스가 NAT 역할을 수행하도록 생성합니다.

AWS에서는 Instace가 NAT 역할을 수행하기 위해서는 2가지 조건이 필요합니다.

> 1. Source_dest_check 설정

```
resource "aws_instance" "ase_instance_nat1" {
  ...
  source_dest_check = false #이 부분이 True로 설정되면 출발지 주소와 인스턴스의 주소가 같지않으면 송수신 하지않음 default가 True로 설정됨
  ...
}
```

> 2. User data ip_forward 설정

User data에서 sysctl을 사용하여 ip_forward 값을 1로 변경하여 활성화 시킬 수도 있지만,

AWS에서 제공하는 NAT Instance의 AMI로 인스턴스를 생성 시 1로 설정된 인스턴스로 생성할 수도 있습니다.

```
cat <<EOF >> /etc/sysctl.conf
net.ipv4.ip_forward=1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.eth0.send_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.eth0.accept_redirects = 0
net.ipv4.conf.ip_vti0.rp_filter = 0
net.ipv4.conf.eth0.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.rp_filter = 0
EOF
sysctl -p /etc/sysctl.conf
```

----

### 3. Inter-region VPC peering

서로 다른 AWS 리전에 있는 VPC 간에 트래픽을 라우팅할 수 있도록 연결하는 서비스입니다. Peering 연결을 통해 VPC는 마치 하나의 네트워크처럼 통신할 수 있습니다.

![image](https://github.com/user-attachments/assets/88919b69-aca7-4386-b522-8d898cd7e8fd)

> 1. Transit Gateway

여러 VPC와 온프레미스 네트워크를 중앙 집중식으로 연결하고 관리하는 서비스입니다. Hub-and-Spoke 모델을 단순화하고 라우팅을 중앙에서 제어할 수 있습니다.

리전간 통신을 위해 Transit gateway를 생성합니다.

```
resource "aws_ec2_transit_gateway" "se_tgw" {
  provider = aws.se
  tags = {
    Name = "se_tgw"
  }
}
resource "aws_ec2_transit_gateway_vpc_attachment" "se_tgw_vpcattach" {
  provider = aws.se
  subnet_ids = [
    aws_subnet.ase_subnet["asn5"].id,
    aws_subnet.ase_subnet["asn6"].id
  ]
  transit_gateway_id = aws_ec2_transit_gateway.se_tgw.id
  vpc_id = aws_vpc.ase_vpc.id
  tags = {
    Name = "se_tgw_vpcattach"
  }
}
```

> 2. Transit gateway VPC peering

두 AWS Transit Gateway (서울/seoul, 싱가포르/singapore)를 피어링하고, 피어링 연결을 수락합니다.

```
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peeringattach" {
  provider = aws.se
  peer_region             = "ap-southeast-1"
  transit_gateway_id      = aws_ec2_transit_gateway.se_tgw.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.si_tgw.id
  tags = {
    Name = "tgw_peeringattach"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peeringattach_accepter" {
  provider                       = aws.si
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach.id
  depends_on = [ aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach ]
  tags = {
    Name = "tgw_peeringattach_accepter"
  }
}
```


> 3. AWS Route

다른 VPC로 보내는 요청을 Transit Gateway로 보내기 위해 aws_route를 작성합니다.

```
resource "aws_route" "ase_route3_tgw" {
  provider = aws.se
  route_table_id            = aws_route_table.ase_routetable["apub1"].id
  destination_cidr_block    = "10.3.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.se_tgw.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}
resource "aws_route" "ase_route4_tgw" {
  provider = aws.se
  route_table_id            = aws_route_table.ase_routetable["apub1"].id
  destination_cidr_block    = "10.4.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.se_tgw.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}
```

> 4. Transit gateway route

Transit Gateway로 요청이 들어갔을 경우 도착지를 설정해주기 위해 aws_ec2_transit_gateway_route를 작성합니다.

```
# Route는 양쪽 리전이 수행되어야 함. 아래 코드는 서울만 예시로 보여줌
resource "aws_ec2_transit_gateway_route" "se_tgw_route3" {
  provider = aws.se
  transit_gateway_route_table_id = aws_ec2_transit_gateway.se_tgw.association_default_route_table_id
  destination_cidr_block = "10.3.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}
resource "aws_ec2_transit_gateway_route" "se_tgw_route4" {
  provider = aws.se
  transit_gateway_route_table_id = aws_ec2_transit_gateway.se_tgw.association_default_route_table_id
  destination_cidr_block = "10.4.0.0/16"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.tgw_peeringattach,
    aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peeringattach_accepter
  ]
}
```

----

### VPN (Virtual Private Network)

Site-to-Site VPN은 온프레미스 네트워크와 AWS VPC를 사설 IP 대역을 사용하여 안전하게 연결하는 서비스입니다. VPN 터널을 통해 암호화된 통신을 제공합니다.

> 구성 요소

- Virtual Private Gateway (VGW): AWS 측 VPN 연결 지점입니다. VPC에 연결됩니다.
- Customer Gateway (CGW): 온프레미스 측 VPN 장비 또는 소프트웨어를 나타냅니다. CGW의 Public IP 주소가 필요합니다.
- VPN Connection: VGW와 CGW 간의 연결을 정의합니다. 두 개의 VPN 터널로 구성되어 고가용성을 제공합니다.

![image](https://github.com/user-attachments/assets/669f684f-dad9-402c-baff-8c6bfc61f6bf)

```
resource "aws_vpn_connection" "isi_cgw_vpnconnection" {
  provider = aws.si
  customer_gateway_id = aws_customer_gateway.isi_cgw.id
  transit_gateway_id  = aws_ec2_transit_gateway.si_tgw.id
  type                = "ipsec.1"
  static_routes_only = true
  tunnel1_preshared_key = "psk_timangs" 
  tunnel2_preshared_key = "psk_timangs"
  tags = {
    Name = "isi_cgw_vpnconnection"
  }
}

resource "aws_route" "isi_vpn1_route" {
  provider = aws.si
  route_table_id = aws_route_table.isi_routetable["ipub1"].id
  destination_cidr_block = "10.1.0.0/16"
  network_interface_id = aws_instance.isi_cgw_instance.primary_network_interface_id
}

resource "aws_route" "isi_vpn3_route" {
  provider = aws.si
  route_table_id = aws_route_table.isi_routetable["ipub1"].id
  destination_cidr_block = "10.2.0.0/16"
  network_interface_id = aws_instance.isi_cgw_instance.primary_network_interface_id
}

resource "aws_route" "isi_vpn4_route" {
  provider = aws.si
  route_table_id = aws_route_table.isi_routetable["ipub1"].id
  destination_cidr_block = "10.3.0.0/16"
  network_interface_id = aws_instance.isi_cgw_instance.primary_network_interface_id
}

resource "aws_ec2_transit_gateway_route" "asi_vpn_route" {
  provider = aws.si
  destination_cidr_block         = "10.4.0.0/16"
  transit_gateway_attachment_id  = aws_vpn_connection.isi_cgw_vpnconnection.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.si_tgw.association_default_route_table_id
}

resource "aws_route" "asi_vpn_route" {
  provider = aws.si
  route_table_id            = aws_route_table.asi_routetable["apub1"].id
  destination_cidr_block    = "10.4.0.0/16"
  transit_gateway_id = aws_ec2_transit_gateway.si_tgw.id
}
```
----
- Customer Gateway

### ELB (Elastic Load Balancer)
ELB는 트래픽을 여러 EC2 인스턴스, 컨테이너 또는 IP 주소로 분산하여 애플리케이션의 가용성과 내결함성을 향상시키는 서비스입니다.

![image](https://github.com/user-attachments/assets/c06a33c5-0381-4391-967a-bf04037e0643)

> 구성 요소

- 로드 밸런서 (Load Balancer): 클라이언트의 요청을 받아 대상 그룹에 분산시키는 역할을 합니다.
  - Application Load Balancer (ALB): HTTP/HTTPS 트래픽 (Layer 7) 로드밸런싱에 적합합니다. 경로 기반 라우팅, 호스트 기반 라우팅 등 고급 기능 제공.
  - Network Load Balancer (NLB): TCP/UDP 트래픽 (Layer 4) 로드밸런싱에 적합합니다. 매우 낮은 지연 시간과 높은 처리량 제공.
  
```
resource "aws_lb" "seoul" {
  provider = aws.seoul
  name               = "seoul-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.seoul.id]
  subnets            = [
    aws_subnet.seoul["sn1"].id,
    aws_subnet.seoul["sn2"].id
  ]
  enable_deletion_protection = false
}
```

- 대상 그룹 (Target Group): 트래픽을 분산시킬 대상 (EC2 인스턴스, 컨테이너 등)의 집합입니다.

```
resource "aws_lb_target_group" "seoul" {
  provider = aws.seoul
  name     = "seoul-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.seoul.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }
}
```

- 리스너 (Listener): 로드 밸런서가 어떤 트래픽을 처리할지 정의하는 부분입니다.

```
resource "aws_lb_listener" "seoul" {
  provider = aws.seoul
  load_balancer_arn = aws_lb.seoul.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.seoul.arn
  }
}
resource "aws_lb_target_group_attachment" "seoul" {
  provider = aws.seoul
  for_each          = {
    seoul_pr1 = aws_instance.seoul_pri1.id
    seoul_pr2 = aws_instance.seoul_pri2.id
  }
  target_group_arn = aws_lb_target_group.seoul.arn
  target_id        = each.value
  port             = 80
}
```

----
### GA(Global Accelerator)
Global Accelerator는 AWS 글로벌 네트워크를 활용하여 사용자와 가장 가까운 엣지 로케이션으로 트래픽을 라우팅하여 애플리케이션의 성능과 가용성을 향상시키는 서비스입니다.
![image](https://github.com/user-attachments/assets/2c129841-154b-42c4-bb00-4fca71382abb)
![image](https://github.com/user-attachments/assets/d44f1a77-7b4a-458b-b81a-f4441bb2722f)

> 구성 요소

- Accelerator: Global Accelerator의 기본 리소스입니다.
- Listener: Accelerator에서 트래픽을 수신하는 포트와 프로토콜을 정의합니다.
- Endpoint Group: 트래픽을 라우팅할 리전별 엔드포인트 그룹입니다.
- Endpoint: 트래픽을 수신하는 실제 리소스 (ALB, NLB, EC2 인스턴스, Elastic IP 주소)입니다.
  
----

### DNS (Domain Name Service)
##### Private DNS 구성
Route 53 Resolver를 사용하여 Private Hosted Zone에 대한 DNS 쿼리를 온프레미스 DNS 서버와 연동하는 구성입니다.
> 구성 요소

- Route 53 Resolver: DNS 쿼리를 확인하고 응답하는 서비스입니다.
- Inbound Endpoint: 온프레미스 DNS 서버에서 VPC 내 Private Hosted Zone으로 DNS 쿼리를 전달하는 데 사용됩니다.
- Outbound Endpoint: VPC 내에서 온프레미스 DNS 서버로 DNS 쿼리를 전달하는 데 사용됩니다.
- Private Hosted Zone: VPC 내에서만 확인 가능한 DNS 레코드를 관리하는 Hosted Zone입니다.

![image](https://github.com/user-attachments/assets/a0d43f27-c61c-4215-8267-dad016aa9793)

----

- Inbound/Outbound Endpoint Resolver
![image](https://github.com/user-attachments/assets/2f369621-77db-4a84-a3ab-da994bb47079)
----
### DB Replication

데이터베이스 복제를 통해 가용성과 재해 복구 기능을 향상시킵니다. 리전 간 복제를 통해 지리적 이중화를 제공할 수 있습니다. 사용하는 데이터베이스 서비스에 따라 구체적인 방법이 달라집니다. (예: RDS, Aurora, DynamoDB 등)

![image](https://github.com/user-attachments/assets/248bf8f1-5b2b-447a-aef7-f167f3f86c8a)
