# 🚀 소상공인 자동 배너광고 서비스 - 프로젝트 인수인계

## 1. 현재 진행 상황
- **단계:** 2단계 (핵심 API & 인증) 완료 -> **3단계 (가게 관리) 시작 직전**
- **날짜:** 2026-02-04
- **개발 환경:**
  - Backend: FastAPI
  - DB: PostgreSQL 17 (Docker Compose 실행 중, Port: 5432)
  - OS: Windows (로컬 uvicorn 실행 중)

## 2. 핵심 구현 내용 (완료됨)
1. **DB 모델링 (소상공인 맞춤형):**
   - `User`: 사업자 정보 (`business_type`, `is_verified`) 포함
   - `Store`: 가게 정보 (`brand_name`, `brand_tone`)
   - `Project`: 광고 캠페인 관리
   - `Content`: AI 생성 결과물 (`ai_config`로 재생성 지원)
2. **인증 시스템 (Auth):**
   - 회원가입 (`/register`): Enum(business_type) 소문자 처리 완료 ✅
   - 로그인 (`/login`): JWT 토큰 발급 정상 작동 ✅
   - 보안: `bcrypt` 해싱, `python-jose` 토큰 처리
3. **인프라:**
   - Docker: `postgres:17-alpine` + `./pg_data` 볼륨 마운트
   - Alembic: 마이그레이션 적용 완료
   - Error Handling: 전역 예외 처리기 적용됨 (500 에러 시 로그 출력)

## 3. 바로 시작해야 할 작업 (Next Step)
**목표:** 3단계 - 가게 정보 관리 (Store Management) 구현

1. **API 구현 (`api/v1/endpoints/stores.py`):**
   - `POST /stores`: 내 가게 등록 (User와 1:N 연결)
   - `GET /stores`: 내 가게 목록 조회
   - `PUT /stores/{id}`: 가게 정보 수정
2. **검증:**
   - Swagger UI에서 로그인 후 받은 토큰(Authorize)을 넣고, 가게 등록이 잘 되는지 테스트.

## 4. 주의 사항 (Troubleshooting)
- **DB 연결:** 로컬 DB 서비스는 꺼둠. Docker 컨테이너(`db`)만 사용 중.
- **접속 주소:** 로컬에서 `uvicorn` 실행 시 `.env`의 DB 호스트는 `localhost`여야 함.
- **Enum 이슈:** DB에 저장할 때 Enum 값은 반드시 **소문자**로 맞춰야 에러 안 남.
