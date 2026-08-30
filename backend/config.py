from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # Postgres connection string, e.g. postgresql+psycopg2://user:password@localhost:5432/screeningtogether
    database_url: SecretStr

    # add api keys here
    # api_key_1: SecretStr
    # api_key_2: SecretStr
    # etc...

settings = Settings()
