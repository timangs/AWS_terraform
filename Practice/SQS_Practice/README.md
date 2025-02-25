#### SQS란?

> AWS에서 제공하는 완전 관리형 메시지 큐 서비스입니다.
> 애플리케이션 구성 요소(컴포넌트) 간에 메시지를 안정적으로 주고받을 수 있게 해줍니다.
> 메시지는 큐에 저장되며, 수신자(consumer)가 처리할 준비가 될 때까지 안전하게 보관됩니다.

#### SQS의 필요성 (핵심):

> 애플리케이션 구성 요소들을 분리하여 서로 직접 통신하지 않고 큐를 통해 메시지를 주고받게 합니다.
> 이렇게 하면 한 구성 요소가 실패하거나 변경되어도 다른 구성 요소에 미치는 영향을 최소화할 수 있습니다. (느슨한 결합)

----

##### Simply Queue Service

![image](https://github.com/user-attachments/assets/21290128-fba9-4a78-b758-4bd4e32ce5a6)

----

##### Bucket

![image](https://github.com/user-attachments/assets/cc0cd917-fbf0-44ed-8de9-c9de1c00e3e1)

> 버킷 정책과 퍼블릭 액세스 차단 비활성화

![image](https://github.com/user-attachments/assets/42fe4a80-9b52-4bc3-acb6-894daae03a45)

----

##### Producer instance

![image](https://github.com/user-attachments/assets/ad9d1bfa-3ab8-4cae-8e0a-b15f3fa812d9)

----

##### Consumer instance

![image](https://github.com/user-attachments/assets/f829db2f-cbfc-486b-b050-21deb984fc75)

----

##### Result

![image](https://github.com/user-attachments/assets/5162ac44-554e-4307-a700-5ccc4ca3cb55)

