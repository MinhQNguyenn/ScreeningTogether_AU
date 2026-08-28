from pydantic_settings import BaseSettings, SettingsConfigDict

# uncomment after a key is added
# from pydantic import SecretStr  


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # add db url and api keys here
    # database_url: SecretStr
    # api_key_1: SecretStr
    # api_key_2: SecretStr
    # etc...

settings = Settings()
