from pydantic import BaseModel
from typing import Optional
from datetime import datetime

from app.models.project import ProjectStatus


class ProjectBase(BaseModel):
    title: str
    description: Optional[str] = None
    status: ProjectStatus = ProjectStatus.DRAFT


class ProjectCreate(ProjectBase):
    store_id: int


class ProjectUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    status: Optional[ProjectStatus] = None


class ProjectInDB(ProjectBase):
    id: int
    store_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class Project(ProjectInDB):
    pass
