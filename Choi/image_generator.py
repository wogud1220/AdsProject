import torch
from diffusers import StableDiffusionXLPipeline
import os
import re

# 모델 및 디바이스 설정
device = "cuda" if torch.cuda.is_available() else "cpu"
model_id = "stabilityai/stable-diffusion-xl-base-1.0"

print(f"[{device}] 이미지 생성 모델 준비 중...")

pipe = StableDiffusionXLPipeline.from_pretrained(
    model_id, 
    torch_dtype=torch.float16 if device == "cuda" else torch.float32, 
    variant="fp16" if device == "cuda" else None,
    use_safetensors=True
)
pipe.to(device)

if device == "cuda":
    pipe.enable_model_cpu_offload()

def generate_ad_image(business_analysis_json):
    # 1. 핵심상품 데이터 처리 (리스트일 경우 첫 번째 항목 사용)
    product_data = business_analysis_json.get("핵심상품", "product")
    if isinstance(product_data, list):
        product_name = product_data[0] # 첫 번째 핵심 상품 추출
    else:
        product_name = product_data

    # 2. 파일명 정제 (문자열로 변환 후 특수문자 제거)
    clean_name = re.sub(r'[^\w\s]', '', str(product_name)).strip().replace(" ", "_")
    
    # 절대 경로 계산
    base_dir = os.path.dirname(os.path.abspath(__file__))
    file_name = f"ad_{clean_name[:20]}.png" # 파일명이 너무 길어지지 않게 20자 제한
    save_path = os.path.join(base_dir, file_name)

    # 3. 프롬프트 구성 (분위기 처리)
    mood_data = business_analysis_json.get("분위기", "trendy")
    moods = ", ".join(mood_data) if isinstance(mood_data, list) else mood_data
    
    pos_prompt = f"Professional food photography, {product_name}, {moods}, highly detailed, 8k, cinematic lighting"
    neg_prompt = "low quality, blurry, text, watermark, logo, messy"

    print(f"\n[이미지 생성 중] 저장 위치: {save_path}")
    
    with torch.inference_mode():
        image = pipe(
            prompt=pos_prompt, 
            negative_prompt=neg_prompt, 
            num_inference_steps=20,
            guidance_scale=7.0
        ).images[0]
    
    image.save(save_path)
    print(f"✅ 이미지 생성 완료!")
    
    return save_path