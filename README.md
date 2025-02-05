![image](https://github.com/user-attachments/assets/301f9b1a-c155-4ca7-83e2-563031effe78)


[1. 사용 권한 설정](##terraform-user-권한-설정)

[2. VPN](###-VPN)

[3. NAT](###-NAT)

[4. ELB](###-ELB)

[5. GA](###-GA\(Global-Acc)

[6. Inter-region](###-inter-region)

[7. DNS](###-DNS)


## terraform user 권한 설정

----

![image](https://github.com/user-attachments/assets/4fc5def1-6db5-44bb-89a6-b03cf2904593)

----

## 필요 구현사항
----
### VPN

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
----
### NAT
NAT Gateway는 Private Subnet의 인스턴스가 인터넷에 연결할 수 있도록 아웃바운드 트래픽을 허용하는 서비스입니다.

![image](https://github.com/user-attachments/assets/04f39d39-dc6f-42c8-a27d-bd9132991dda)

----
### ELB
ELB는 트래픽을 여러 EC2 인스턴스, 컨테이너 또는 IP 주소로 분산하여 애플리케이션의 가용성과 내결함성을 향상시키는 서비스입니다.

![image](https://github.com/user-attachments/assets/c06a33c5-0381-4391-967a-bf04037e0643)
> 종류
- Application Load Balancer (ALB): HTTP/HTTPS 트래픽 (Layer 7) 로드밸런싱에 적합합니다. 경로 기반 라우팅, 호스트 기반 라우팅 등 고급 기능 제공.
- Network Load Balancer (NLB): TCP/UDP 트래픽 (Layer 4) 로드밸런싱에 적합합니다. 매우 낮은 지연 시간과 높은 처리량 제공.

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
### Inter-region VPC peering
서로 다른 AWS 리전에 있는 VPC 간에 트래픽을 라우팅할 수 있도록 연결하는 서비스입니다. Peering 연결을 통해 VPC는 마치 하나의 네트워크처럼 통신할 수 있습니다.
![image](https://github.com/user-attachments/assets/88919b69-aca7-4386-b522-8d898cd7e8fd)
- Transit Gateway
여러 VPC와 온프레미스 네트워크를 중앙 집중식으로 연결하고 관리하는 서비스입니다. Hub-and-Spoke 모델을 단순화하고 라우팅을 중앙에서 제어할 수 있습니다.
----
### DNS 설정
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
