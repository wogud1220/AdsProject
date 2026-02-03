# Choi/copywriter.py
import os
from openai import OpenAI

def generate_ad_copy(analysis_result):
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY").strip().replace('\u2069', ''))
    
    prompt = f"""
    소상공인을 위한 SNS 광고 문구를 작성해줘.
    [정보]
    - 업종: {analysis_result['업종']}
    - 핵심상품: {analysis_result['핵심상품']}
    - 타겟: {analysis_result['타겟층']}
    - 분위기: {analysis_result['분위기']}

    [요구사항]
    1. 인스타그램용: 트렌디한 말투, 이모지 적극 활용, 해시태그 5개
    2. 유튜브 홍보용: 지역 주민에게 친근한 말투, '육즙' 강조
    """

    response = client.chat.completions.create(
        model="gpt-5-mini",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content