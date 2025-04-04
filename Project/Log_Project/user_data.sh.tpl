#!/bin/bash
set -e
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "User data 스크립트 시작..."
echo "패키지 업데이트 중..."
sudo yum update -y

echo "Docker 설치 중..."
sudo amazon-linux-extras install docker -y
echo "Docker 서비스 시작 및 활성화..."
sudo systemctl start docker
sudo systemctl enable docker

echo "ec2-user를 docker 그룹에 추가 중..."
sudo usermod -aG docker ec2-user

echo "Docker Compose v2 플러그인 설치 중..."
# 셸 변수 대신 경로 직접 사용
echo "Compose 플러그인 디렉토리 생성: /usr/libexec/docker/cli-plugins"
sudo mkdir -p /usr/libexec/docker/cli-plugins
echo "Compose 플러그인 다운로드 중..."
sudo curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/libexec/docker/cli-plugins/docker-compose
echo "Compose 플러그인 실행 권한 부여 중..."
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
echo "Docker Compose 설치 완료 (경로: /usr/libexec/docker/cli-plugins)."

echo "Docker 서비스 재시작 시도 (플러그인 인식 목적)..."
sudo systemctl restart docker
sleep 5 # Docker 재시작 후 안정화를 위해 잠시 대기

echo "Docker 버전:"
docker --version
echo "Docker Compose 버전 확인 시도 ('docker compose version'):"
# 'docker compose' 명령어는 여전히 불안정할 수 있음
docker compose version || echo "*** 'docker compose version' 실패 (예상될 수 있음) ***"

echo "Docker Compose 버전 확인 시도 (직접 실행):"
# 직접 실행은 성공해야 함
sudo /usr/libexec/docker/cli-plugins/docker-compose version || echo "*** 직접 실행 실패! ***"


# 셸 변수 대신 경로 직접 사용
echo "애플리케이션 디렉토리 생성: /home/ec2-user/app"
sudo mkdir -p /home/ec2-user/app

echo "애플리케이션 디렉토리로 이동: /home/ec2-user/app"
cd /home/ec2-user/app

# docker-compose.yml 생성 (Base64 디코딩)
echo "docker-compose.yml 생성 중 (Base64 decoding)..."
cat <<EOF | base64 --decode > docker-compose.yml
${docker_compose_b64}
EOF
echo "docker-compose.yml 생성 완료."

# 파일 소유권 변경 (ec2-user로) - 현재 디렉토리(.)에 적용
echo "현재 디렉토리(/home/ec2-user/app) 파일 소유권 변경 중..."
sudo chown -R ec2-user:ec2-user .

# 현재 디렉토리는 이미 /home/ec2-user/app 임
echo "Docker Compose 실행 (직접 실행 방식 사용)..."
# 'docker compose' 명령어 대신 안정적인 직접 실행 방식만 사용
sudo /usr/libexec/docker/cli-plugins/docker-compose up -d

echo "User data 스크립트 성공적으로 완료."