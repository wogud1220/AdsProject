from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class StoreBase(BaseModel):
    brand_name: str = Field(..., min_length=1, max_length=100, description="브랜드 이름")
    brand_tone: Optional[str] = Field(None, max_length=200, description="브랜드 톤앤매너")
    description: Optional[str] = Field(None, max_length=500, description="가게 설명")


class StoreCreate(StoreBase):
    pass


class StoreUpdate(BaseModel):
    brand_name: Optional[str] = Field(None, min_length=1, max_length=100, description="브랜드 이름")
    brand_tone: Optional[str] = Field(None, max_length=200, description="브랜드 톤앤매너")
    description: Optional[str] = Field(None, max_length=500, description="가게 설명")


class StoreResponse(StoreBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class StoreInDB(StoreResponse):
    pass


class Store(StoreInDB):
    pass
