# ADS Project

광고 카피 생성 및 이미지 생성을 위한 FastAPI 백엔드 프로젝트

## 📁 프로젝트 구조

```
ads_project/
├── backend/                    # FastAPI 백엔드
│   ├── app/                   # 애플리케이션 코드
│   ├── alembic/              # 데이터베이스 마이그레이션
│   ├── scripts/              # AI 모델 테스트 스크립트
│   ├── test_models/          # AI 모델 파일 (로컬)
│   ├── venv/                 # 가상환경
│   ├── .env                  # 환경 변수 (민감 정보)
│   ├── .env.example          # 환경 변수 템플릿
│   ├── docker-compose.yml    # PostgreSQL 설정
│   └── requirements.txt      # Python 의존성
├── frontend/                  # (향후 추가 예정)
└── README.md                 # 프로젝트 설명
```

## 🚀 빠른 시작

### 1. 환경 설정
```bash
# 백엔드 폴더로 이동
cd backend

# 가상환경 생성 및 활성화
python -m venv venv
venv\Scripts\activate

# 의존성 설치
pip install -r requirements.txt
```

### 2. 환경 변수 설정
```bash
# 환경 변수 파일 복사
cp .env.example .env

# .env 파일 수정 (데이터베이스 비밀번호 등)
```

### 3. 데이터베이스 시작
```bash
# Docker PostgreSQL 시작
docker-compose up -d
```

### 4. 애플리케이션 실행
```bash
# FastAPI 서버 시작
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 📋 기능

### ✅ 구현된 기능
- **사용자 인증**: JWT 기반 회원가입/로그인
- **가게 관리**: CRUD API 엔드포인트
- **데이터베이스**: PostgreSQL + Alembic 마이그레이션
- **AI 모델**: LLM 및 이미지 생성 테스트 스크립트

### 🔄 개발 중인 기능
- 광고 캠페인 관리
- AI 기반 카피 생성
- 이미지 생성 통합

## 🔧 개발 환경

- **Python**: 3.9+
- **FastAPI**: 웹 프레임워크
- **PostgreSQL**: 데이터베이스
- **Docker**: 컨테이너화
- **Alembic**: 데이터베이스 마이그레이션

## 📖 API 문서

서버 실행 후 다음 주소로 접속:
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🤝 팀원 가이드

### 새로운 팀원
```bash
# 1. 프로젝트 클론
git clone <repository-url>
cd ads_project

# 2. 백엔드 설정
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt

# 3. 환경 설정
cp .env.example .env
# .env 파일에 실제 값 입력

# 4. 데이터베이스 시작
docker-compose up -d

# 5. 서버 실행
uvicorn app.main:app --reload
```

## 🔒 보안

- `.env` 파일은 `.gitignore`에 포함되어 GitHub에 올라가지 않음
- 데이터베이스 비밀번호는 환경 변수로 관리
- API 키 및 민감 정보는 환경 변수로 분리

## 📝 라이선스

MIT License
