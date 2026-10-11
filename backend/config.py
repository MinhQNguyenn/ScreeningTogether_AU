from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # Postgres connection address
    database_url: SecretStr

    # add api keys here
    # api_key_1: SecretStr
    # api_key_2: SecretStr
    # etc...

    gemini_api_key: SecretStr | None = None
    gemini_live_model: str = "gemini-3.8-live"
    gemini_live_voice: str = "Kore"

    rag_pipeline_version: str = "v2-no-classifier"

    rag_embedding_model: str = (
        "gemini-embedding-001"
    )

    rag_embedding_dimensions: int = 768

settings = Settings()
