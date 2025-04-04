# 1. AWS Lambda Python 런타임과 유사한 공식 베이스 이미지 사용
# 사용하려는 Lambda 함수의 Python 버전에 맞춰 태그 변경 (예: 3.11, 3.10 등)
FROM public.ecr.aws/lambda/python:3.13

# 2. 작업 디렉토리 생성 (컨테이너 내부 경로)
WORKDIR /layer-build

# 3. requirements.txt 파일을 컨테이너 안으로 복사
COPY requirements.txt .

# 4. pip를 사용하여 라이브러리를 Lambda Layer 구조에 맞게 설치
#    Lambda는 '/opt/python' 경로에서 라이브러리를 찾으므로,
#    압축할 때 'python' 폴더 아래에 설치되도록 함.
RUN pip install -r requirements.txt -t ./python/

# 5. (선택 사항) 빌드 완료 후 쉽게 복사하기 위해 임시 명령 추가 가능
# CMD ["echo", "Layer dependencies built into 'python' directory."]