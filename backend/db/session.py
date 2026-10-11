from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from config import settings

# pre-ping replaces a dead connection instead of erroring on first use.
engine = create_engine(
    settings.database_url.get_secret_value(),
    pool_pre_ping=True,
)
SessionLocal = sessionmaker(bind=engine)
