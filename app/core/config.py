from pydantic_settings import BaseSettings
import secrets


class Settings(BaseSettings):
    # Database
    DATABASE_URL: str
    
    # Security
    SECRET_KEY: str = secrets.token_urlsafe(32)
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Application
    APP_NAME: str = "FastAPI ADS Project"
    DEBUG: bool = True
    
    class Config:
        env_file = ".env"


settings = Settings()
