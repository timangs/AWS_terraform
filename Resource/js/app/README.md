![image](https://github.com/user-attachments/assets/975052e4-3ff8-4b45-899e-8a42179f3728)

<details>
<summary>Script</summary>

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
. ~/.nvm/nvm.sh
nvm install --lts
nvm install 16.18.0
npm audit fix --force
npm uninstall nodemon
npm install nodemon@latest
npm install aws-sdk
npm install
npm start
```

### Prerequisite

npm install 이후 /var/app/api/common/constants.js 에서 설정값을 넣어준다

> PHOTOS_BUCKET, DEFAULT_AWS_REGION, TABLE_NAME etc.
  
</details>

![image](https://github.com/user-attachments/assets/ece46b5b-70f6-409a-974e-88fad30c1214)

![image](https://github.com/user-attachments/assets/5e5ce954-35bb-476f-a093-c85a9b12aca6)

![image](https://github.com/user-attachments/assets/718e9b27-21b4-454f-a33d-139cfa8a0f7f)

![image](https://github.com/user-attachments/assets/cf09c362-d79d-4f31-945f-cedda861a828)

![image](https://github.com/user-attachments/assets/289cf5c5-b715-4105-a173-3699714f45b4)

![image](https://github.com/user-attachments/assets/e0e4ba70-a313-4483-af1b-cd94d70e5541)
