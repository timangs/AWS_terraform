```
# connection Instance에서 RDS 접근 시
mysql -uadmin -p -h database-1.xxxxxxxx637.ap-northeast-2.rds.amazonaws.com
#RDS 인스턴스 생성시 비밀번호 timangs123로 생성하였음
```

### AWS RDS 특징

> RDS Software Patch 는 CSP에서 해주므로 Client 측에서 하지않는다.

> VPC에 종속적이고 기본적으로 public ip를 부여하지 않아 외부에서 접근이 불가능하지만 설정에 따라 Public부여가 가능합니다.

> 암호화된 SQL Server DB Instance는 백업 복제가 지원되지 않습니다.

<details>
<summary>특정 시점으로 복원</summary>
  
![image](https://github.com/user-attachments/assets/da2d1eec-a5d5-49f1-bae5-d862e4479144)

![image](https://github.com/user-attachments/assets/05ad0826-74c6-4156-88c5-b92b7eeab94a)

![image](https://github.com/user-attachments/assets/33786907-2c8d-408c-a62f-52afe26cd55c)

![image](https://github.com/user-attachments/assets/8f185918-c187-4438-a9e5-9d4c3f363943)

RDS에서 복원하게 되면 새로운 Instance로 생성된다.

</details>

<details>
<summary>스냅샷을 이용한 수동 복원</summary>

![image](https://github.com/user-attachments/assets/2668ad07-b609-44d2-99c4-39d289952290)

![image](https://github.com/user-attachments/assets/9e19a0d9-087c-4151-b831-4bb5293f1e60)

![image](https://github.com/user-attachments/assets/5c1303e2-7f72-46a7-b268-15a8c715d025)

![image](https://github.com/user-attachments/assets/514b4857-5282-4261-b79a-01d428a75098)


특정 시점으로 복원과 달리 설정이 동일하게 입력되지 않기 때문에 생성 시에 내용을 잘 확인해야 한다.

</details>

<details>
<summary>교차 리전 백업</summary>

![image](https://github.com/user-attachments/assets/3ddc4538-34df-46be-9667-ee8ca3130f2d)

![image](https://github.com/user-attachments/assets/22e1c21a-f94b-4467-b68c-5d7367ec6236)

![image](https://github.com/user-attachments/assets/3377db2c-bfe4-4be4-b318-29243a26fab6)

KMS 키가 필요하지만 본 Database Instance는 Terraform에 의해 생성되어 KMS키를 별도로 요구하지 않는다.

</details>

<details>
<summary>RDS Instance삭제 시 주의사항</summary>

![image](https://github.com/user-attachments/assets/c3d1f6ea-19e8-4e56-8234-7de8ae4eea1e)

최종 스냅샷은 RDS 인스턴스 삭제 직전의 마지막 백업입니다. 실수로 삭제하거나, 삭제 후 데이터 복구가 필요할 때를 대비하는 기능입니다.

자동 백업 보존은 RDS 인스턴스 삭제 후에도 기존에 자동으로 생성되었던 백업들을 일정 기간 동안 유지합니다. 삭제 후에도 이전 시점으로 복구할 가능성을 남겨둡니다.

단, 지금은 테스트로 생성하여 유실될 데이터가 없기 때문에 체크를 해제하여 삭제하여 추가적인 비용이 청구되지 않도록 합니다.

</details>

<details>
<summary>읽기 전용 복제본 생성</summary>
  
![image](https://github.com/user-attachments/assets/52028eda-8fb1-4d59-84b2-42959e0c8399)

자동 백업이 활성화 되어야 읽기 전용 복제본을 생성할 수 있다.

![image](https://github.com/user-attachments/assets/f8767e4d-5ccb-4a42-8fbc-3f176bb359a1)

![image](https://github.com/user-attachments/assets/f67edb9c-57dc-4e22-a32d-85bba3e1a7c2)

</details>
