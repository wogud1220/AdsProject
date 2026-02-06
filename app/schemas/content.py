from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime

from app.models.content import ContentType


class ContentBase(BaseModel):
    type: ContentType
    user_prompt: Optional[str] = None
    ai_config: Optional[Dict[str, Any]] = None


class ContentCreate(ContentBase):
    project_id: int
    original_image_path: Optional[str] = None


class ContentUpdate(BaseModel):
    result_image_path: Optional[str] = None
    ad_copy: Optional[str] = None
    ai_config: Optional[Dict[str, Any]] = None
    is_success: Optional[bool] = None
    error_message: Optional[str] = None


class ContentInDB(ContentBase):
    id: int
    project_id: int
    original_image_path: Optional[str] = None
    result_image_path: Optional[str] = None
    ad_copy: Optional[str] = None
    generation_time: Optional[int] = None
    is_success: bool
    error_message: Optional[str] = None
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class Content(ContentInDB):
    pass


class ContentGenerate(BaseModel):
    type: ContentType
    user_prompt: str
    ai_config: Optional[Dict[str, Any]] = None
    original_image_path: Optional[str] = None  # For image processing types
