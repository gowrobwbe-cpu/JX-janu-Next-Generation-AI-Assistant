import os
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    APP_NAME: str = "JX AI Companion Backend"
    VERSION: str = "1.0.0"
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    DATABASE_URL: str = "sqlite+aiosqlite:///./jx_companion_backend.db"
    CREATOR_NAME: str = "Gowrob"

    class Config:
        env_file = ".env"

settings = Settings()
