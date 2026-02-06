import os
os.environ['PYTHONIOENCODING'] = 'utf-8'

import sys
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from app.core.security import get_password_hash
from app.schemas.user import UserCreate
from app.models.user import BusinessType

def test_components():
    """개별 컴포넌트 테스트"""
    print("=== 컴포넌트 테스트 ===")
    
    # 1. 비밀번호 해싱 테스트
    try:
        password = "password123"
        hashed = get_password_hash(password)
        print(f"비밀번호 해싱 성공: {hashed[:50]}...")
    except Exception as e:
        print(f"비밀번호 해싱 실패: {e}")
        return False
    
    # 2. Pydantic 스키마 테스트
    try:
        user_data = {
            "email": "test@example.com",
            "username": "testuser",
            "password": "password123",
            "business_type": BusinessType.RESTAURANT
        }
        user = UserCreate(**user_data)
        print(f"Pydantic 스키마 성공: {user.email}")
    except Exception as e:
        print(f"Pydantic 스키마 실패: {e}")
        return False
    
    print("모든 컴포넌트 테스트 성공!")
    return True

if __name__ == "__main__":
    test_components()
