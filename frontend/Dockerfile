# 1. Python 베이스 이미지
FROM python:3.12-slim

# 2. 작업 디렉토리 설정
WORKDIR /app

# 3. 의존성 파일 복사
COPY requirements.txt .

# 4. 의존성 설치
RUN pip install --no-cache-dir -r requirements.txt

# 5. 소스 코드 복사
COPY . .

# 6. Streamlit 포트
EXPOSE 8501

# 7. Streamlit 실행
CMD ["streamlit", "run", "main.py", "--server.address=0.0.0.0", "--server.port=8501"]