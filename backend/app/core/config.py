import os
from dotenv import load_dotenv

# Load environment variables from .env if present
load_dotenv()


class Settings:
    PROJECT_NAME: str = os.getenv("PROJECT_NAME", "EcoLoop API")
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    API_V1_PREFIX: str = os.getenv("API_V1_PREFIX", "/api/v1")

    # Firebase configuration
    FIREBASE_PROJECT_ID: str = os.getenv("FIREBASE_PROJECT_ID", "ecoloop-3fd3b")
    FIREBASE_CREDENTIALS_PATH: str = os.getenv("FIREBASE_CREDENTIALS_PATH", "")
    ALLOW_DEV_AUTH_TOKEN: bool = os.getenv("ALLOW_DEV_AUTH_TOKEN", "true").lower() in ("true", "1", "yes")


settings = Settings()
