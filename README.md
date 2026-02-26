# AdsProject
# AI 마케팅 콘텐츠 생성 서비스 (Backend)

FastAPI 기반의 AI 마케팅 콘텐츠 생성 백엔드 서비스입니다. FLUX.1-schnell 모델을 사용하여 고품질 이미지를 생성하고, LLM을 통해 광고 문구를 최적화합니다.

이상윤 협업일지 링크주소: https://www.notion.so/Daily-1-1-313d0a925d2480cc8796f9a7b391088d

## 🚀 기술 스택

- **Framework**: FastAPI 0.104.1
- **Database**: SQLite
- **AI Models**: 
  - FLUX.1-schnell (NF4 양자화 버전)
  - OpenAI GPT (프롬프트 최적화 및 광고 문구 생성)
- **Python**: 3.10+
- **Image Generation**: Diffusers, PyTorch

## 📦 설치 및 실행

### 1. 저장소 복제
```bash
git clone <repository-url>
cd ads_project/backend
```

### 2. 가상환경 설정
```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
```

### 3. 의존성 설치
```bash
pip install -r requirements.txt
```

### 4. 환경 변수 설정
`.env` 파일을 생성하고 다음 내용을 추가하세요:

```env
# 데이터베이스
DATABASE_URL=sqlite:///./app.db

# 보안
SECRET_KEY=your-secret-key-here
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# 애플리케이션
APP_NAME=AI Marketing Content Generator
APP_VERSION=1.0.0
DEBUG=True

# OpenAI API
OPENAI_API_KEY=your-openai-api-key

# HuggingFace (모델 다운로드용)
HF_TOKEN=your-huggingface-token
```

### 5. 서버 실행
```bash
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 🤖 모델 정보

### FLUX.1-schnell (NF4 양자화)
- **모델**: [Keffisor21/flux1-schnell-bnb-nf4](https://huggingface.co/Keffisor21/flux1-schnell-bnb-nf4)
- **특징**: 
  - NF4 양자화로 VRAM 사용량 75% 감소
  - CPU 오프로드 지원
  - 빠른 생성 속도 (1-4 스텝)
- **다운로드**: 최초 실행 시 자동 다운로드되거나, 수동 다운로드 가능

## 📚 API 문서

서버 실행 후 다음 URL에서 API 문서를 확인할 수 있습니다:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 🔑 주요 API 엔드포인트

### 인증
- `POST /api/v1/auth/login` - 로그인
- `POST /api/v1/auth/register` - 회원가입

### 콘텐츠 생성
- `POST /api/v1/contents/generate` - AI 콘텐츠 생성
- `GET /api/v1/contents/{id}/image` - 생성된 이미지 조회

### 가게/프로젝트 관리
- `GET/POST/PUT/DELETE /api/v1/stores` - 가게 관리
- `GET/POST/PUT/DELETE /api/v1/projects` - 프로젝트 관리

## 🖼️ 이미지 생성 예시

```python
import requests

# 이미지 생성 요청
response = requests.post(
    "http://localhost:8000/api/v1/contents/generate",
    json={
        "ad_description": "따뜻한 커피를 파는 카페",
        "image_prompt": "따뜻한 분위기의 카페 내부, 커피 잔, 햇살",
        "text_in_image": "Best Coffee",
        "project_id": 1,
        "seed": 12345
    },
    headers={"Authorization": "Bearer your-token"}
)

result = response.json()
print(f"생성된 이미지 URL: {result['image_url']}")
print(f"최적화된 프롬프트: {result['optimized_prompt']}")
print(f"광고 문구: {result['ad_copy']}")
```

## 🗂️ 프로젝트 구조

```
backend/
├── app/
│   ├── api/v1/          # API 라우터
│   ├── core/            # 설정 및 보안
│   ├── crud/            # 데이터베이스 CRUD
│   ├── db/              # 데이터베이스 설정
│   ├── models/          # 데이터 모델
│   └── services/        # 비즈니스 로직
├── outputs/txt2img/     # 생성된 이미지 저장
├── requirements.txt     # 의존성 목록
└── .env                 # 환경 변수
```

## 🔧 트러블슈팅

### 404 에러 (이미지)
- `outputs/txt2img` 폴더가 있는지 확인
- 파일명이 정확한지 확인
- 권한이 있는지 확인

### 모델 로딩 에러
- 인터넷 연결 확인 (최초 다운로드 시)
- HuggingFace 토큰 확인
- VRAM 공간 확인 (NF4 버전으로 최적화됨)

### bcrypt 에러
```bash
pip install bcrypt==4.0.1
```

## 📝 개발 참고사항

- 데이터베이스는 SQLite를 사용하며, `app.db` 파일에 저장됩니다.
- 생성된 이미지는 `outputs/txt2img/` 폴더에 저장됩니다.
- FLUX 모델은 Lazy Loading 방식으로, 최초 요청 시 로드됩니다.
- 모든 API는 JWT 토큰 인증이 필요합니다.

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
