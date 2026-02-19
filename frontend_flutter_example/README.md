# AI 광고 배너 생성기 Flutter 앱

소상공인을 위한 AI 광고 배너 자동 생성 애플리케이션 MVP

## 기능 개요

- **AI 이미지 생성**: 사용자가 입력한 광고 문구로 AI 광고 배너 생성
- **샘플러 선택**: 12가지 샘플러 옵션으로 생성 스타일 조절
- **실시간 미리보기**: 생성된 이미지 즉시 확인
- **에러 처리**: 네트워크 오류 및 서버 오류 사용자 친화적 표시

## 기술 스택

- **Flutter**: Material 3 디자인 시스템
- **HTTP**: RESTful API 통신
- **상태 관리**: setState (간단한 상태 관리)

## 실행 방법

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 백엔드 서버 실행
```bash
# backend 폴더에서
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. 앱 실행
```bash
# Web (Chrome) 환경
flutter run -d chrome

# 안드로이드 에뮬레이터 환경
flutter run
```

## API 연동 정보

### 백엔드 엔드포인트
- **Web URL**: `http://127.0.0.1:8000/api/v1/contents/generate`
- **모바일 URL**: `http://10.0.2.2:8000/api/v1/contents/generate`
- **메서드**: POST
- **인증**: 현재 테스트용으로 인증 없음 (향후 JWT 토큰 추가 예정)

### 요청 파라미터
```json
{
  "prompt": "광고 문구",
  "negative_prompt": "",
  "cfg": 1.0,
  "sampler_name": "euler",
  "scheduler": "simple",
  "steps": 8,
  "width": 1024,
  "height": 1024,
  "seed": 12345
}
```

### 응답 형식
```json
{
  "success": true,
  "message": "이미지가 성공적으로 생성되었습니다.",
  "image_path": "outputs/txt2img/qwen_result_20260209_170957_60_0.png",
  "image_url": "/images/qwen_result_20260209_170957_60_0.png",
  "content_id": 1,
  "generation_time": 8.5
}
```

## UI 구성

### 메인 화면
1. **앱 바**: "AI 광고 배너 생성기" 타이틀
2. **입력 폼**:
   - 광고 문구 입력 (TextField, 3줄)
   - 샘플러 선택 (DropdownButton)
3. **생성 버튼**: 로딩 중엔 CircularProgressIndicator 표시
4. **결과 영역**: 생성된 이미지 표시 (Image.network)
5. **에러 메시지**: 오류 발생 시 사용자 친화적 메시지

### 지원되는 샘플러
- euler, euler_ancestral, heun, dpm_2, dpm_2_ancestral
- lms, dpm_fast, dpm_adaptive, dpmpp_2s_ancestral
- dpmpp_sde, dpmpp_2m, ddim

## 개발 환경

### Web (Chrome)
- **백엔드 주소**: `http://127.0.0.1:8000`
- **이미지 접근**: `http://127.0.0.1:8000/images/{filename}`
- **실행 명령**: `flutter run -d chrome`

### 안드로이드 에뮬레이터
- **백엔드 주소**: `http://10.0.2.2:8000`
- **이미지 접근**: `http://10.0.2.2:8000/images/{filename}`
- **실행 명령**: `flutter run`

### 실제 기기
- **백엔드 주소**: `http://[PC_IP]:8000`
- **같은 WiFi 네트워크 필요**

## 테스트 시나리오

1. **정상 흐름**:
   - 광고 문구 입력 → 샘플러 선택 → 생성 버튼 클릭
   - 로딩 표시 → 이미지 생성 완료 → 결과 표시

2. **에러 케이스**:
   - 빈 문구 입력 → 유효성 검사 에러
   - 네트워크 오류 → 에러 메시지 표시
   - 서버 오류 → 상태 코드와 메시지 표시

3. **이미지 로딩**:
   - 로딩 중 표시
   - 로딩 실패 시 에러 아이콘 표시

## 향후 개선사항

1. **인증 통합**: JWT 토큰 기반 인증 추가
2. **프로젝트 관리**: 프로젝트 생성/선택 기능
3. **이미지 저장**: 생성된 이미지 갤러리 저장
4. **고급 옵션**: 더 많은 생성 파라미터 제어
5. **실시간 진행률**: WebSocket으로 생성 진행률 표시
6. **이미지 편집**: 생성된 이미지 기본 편집 기능

## 연동 테스트

앱 실행 전 백엔드 서버가 반드시 실행 중이어야 합니다:

```bash
# backend 폴더에서
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

서버 상태 확인:
```bash
curl http://localhost:8000/health
```

---
 
**이 Flutter 앱은 FastAPI 백엔드와의 완벽한 통합을 통해 AI 광고 배너 생성 서비스의 전체 사용자 경험을 검증합니다.**
