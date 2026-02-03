import os
import json
import sys
from openai import OpenAI
from dotenv import load_dotenv

# 내부 모듈 불러오기
from image_generator import generate_ad_image
from copywriter import generate_ad_copy

# 출력 인코딩 설정
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8', errors='ignore')

load_dotenv()

def analyze_business(user_text):
    """1단계: gpt-5-mini 기반 정보 분석"""
    raw_key = os.getenv("OPENAI_API_KEY")
    clean_key = raw_key.strip().replace('\u2069', '') if raw_key else None
    client = OpenAI(api_key=clean_key)
    
    response = client.chat.completions.create(
        model="gpt-5-mini",
        messages=[
            {"role": "system", "content": "너는 소상공인 마케팅 전문가야. 업종, 핵심상품, 타겟층, 분위기를 포함한 JSON으로만 답해줘."},
            {"role": "user", "content": user_text}
        ],
        response_format={"type": "json_object"}
    )
    return json.loads(response.choices[0].message.content)

def main():
    user_input = "홍대 입구역 근처 작은 수제버거 집, 육즙 가득한 패티가 특징이야."
    
    try:
        # 1. 분석
        print(f"\n[1/3] 사업자 정보 분석 중...")
        analysis_result = analyze_business(user_input)
        print("--- 분석 결과 ---")
        print(json.dumps(analysis_result, indent=4, ensure_ascii=False))
        
        # 2. 이미지 생성
        print(f"\n[2/3] 광고 이미지 생성 중 (약 15초)...")
        image_path = generate_ad_image(analysis_result)
        
        # 3. 문구 생성
        print(f"\n[3/3] 맞춤형 광고 카피 작성 중...")
        ad_copy = generate_ad_copy(analysis_result)
        
        print("\n" + "="*50)
        print("✨ 소상공인 AI 광고 패키지 완성 ✨")
        print("="*50)
        print(ad_copy)
        print("="*50)
        print(f"📸 이미지 확인: {image_path}")
        
    except Exception as e:
        print(f"\n❌ 실행 오류: {e}")

if __name__ == "__main__":
    main()