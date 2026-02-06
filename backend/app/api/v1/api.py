from fastapi import APIRouter

from app.api.v1.endpoints import auth, stores

api_router = APIRouter()

api_router.include_router(auth.router, prefix="/auth", tags=["인증"])
api_router.include_router(stores.router, prefix="/stores", tags=["가게 관리"])
