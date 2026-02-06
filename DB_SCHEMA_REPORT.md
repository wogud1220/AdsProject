# 데이터베이스 스키마 검증 보고서

**생성 시간:** 2026-02-04 17:38:15
**데이터베이스:** app_db (PostgreSQL)

---

## 1. 테이블 목록

총 5개의 테이블이 발견되었습니다:
- ⚠️ `alembic_version`
- ✅ `contents`
- ✅ `projects`
- ✅ `stores`
- ✅ `users`

## 2. 테이블 스키마 상세 정보

### USERS 테이블

| 컬럼명 | 데이터 타입 | NULL 허용 | 기본값 | 예상 타입 | 상태 |
|--------|------------|-----------|--------|----------|------|
| `id` | integer | NO | nextval('users_id_seq'::regclass) | integer | ✅ |
| `email` | character varying | NO | None | character varying | ✅ |
| `username` | character varying | NO | None | character varying | ✅ |
| `password_hash` | character varying | NO | None | character varying | ✅ |
| `business_type` | USER-DEFINED | NO | None | USER-DEFINED | ✅ |
| `is_verified` | boolean | NO | None | boolean | ✅ |
| `is_active` | boolean | NO | None | boolean | ✅ |
| `created_at` | timestamp with time zone | YES | now() | timestamp with time zone | ✅ |
| `updated_at` | timestamp with time zone | YES | None | timestamp with time zone | ✅ |

### STORES 테이블

| 컬럼명 | 데이터 타입 | NULL 허용 | 기본값 | 예상 타입 | 상태 |
|--------|------------|-----------|--------|----------|------|
| `id` | integer | NO | nextval('stores_id_seq'::regclass) | integer | ✅ |
| `user_id` | integer | NO | None | integer | ✅ |
| `brand_name` | character varying | NO | None | character varying | ✅ |
| `brand_tone` | character varying | NO | None | character varying | ✅ |
| `description` | text | YES | None | text | ✅ |
| `created_at` | timestamp with time zone | YES | now() | timestamp with time zone | ✅ |
| `updated_at` | timestamp with time zone | YES | None | timestamp with time zone | ✅ |

### PROJECTS 테이블

| 컬럼명 | 데이터 타입 | NULL 허용 | 기본값 | 예상 타입 | 상태 |
|--------|------------|-----------|--------|----------|------|
| `id` | integer | NO | nextval('projects_id_seq'::regclass) | integer | ✅ |
| `store_id` | integer | NO | None | integer | ✅ |
| `title` | character varying | NO | None | character varying | ✅ |
| `description` | text | YES | None | text | ✅ |
| `status` | USER-DEFINED | NO | None | USER-DEFINED | ✅ |
| `created_at` | timestamp with time zone | YES | now() | timestamp with time zone | ✅ |
| `updated_at` | timestamp with time zone | YES | None | timestamp with time zone | ✅ |

### CONTENTS 테이블

| 컬럼명 | 데이터 타입 | NULL 허용 | 기본값 | 예상 타입 | 상태 |
|--------|------------|-----------|--------|----------|------|
| `id` | integer | NO | nextval('contents_id_seq'::regclass) | integer | ✅ |
| `project_id` | integer | NO | None | integer | ✅ |
| `type` | USER-DEFINED | NO | None | USER-DEFINED | ✅ |
| `original_image_path` | character varying | YES | None | character varying | ✅ |
| `result_image_path` | character varying | YES | None | character varying | ✅ |
| `ad_copy` | text | YES | None | text | ✅ |
| `user_prompt` | text | YES | None | text | ✅ |
| `ai_config` | json | YES | None | json | ✅ |
| `generation_time` | integer | YES | None | integer | ✅ |
| `is_success` | character varying | NO | None | boolean | ⚠️ |
| `error_message` | text | YES | None | text | ✅ |
| `created_at` | timestamp with time zone | YES | now() | timestamp with time zone | ✅ |
| `updated_at` | timestamp with time zone | YES | None | timestamp with time zone | ✅ |

## 3. Foreign Key 관계

### 예상되는 관계:
- `stores.user_id` → `users.id` (1:N)
- `projects.store_id` → `stores.id` (1:N)
- `contents.project_id` → `projects.id` (1:N)

### 실제 Foreign Key 제약조건:

✅ `contents.project_id` → `projects.id`
✅ `projects.store_id` → `stores.id`
✅ `stores.user_id` → `users.id`

---

## 4. 검증 요약

- **테이블 수:** 4/4
- **Foreign Key 수:** 3/3

### 상태:
✅ **모든 스키마 검증 통과!**