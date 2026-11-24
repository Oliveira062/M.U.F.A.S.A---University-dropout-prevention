from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

# Setup of a local file-based SQLite database (.db)
SQLALCHEMY_DATABASE_URL = "sqlite:///./mufasa.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
  """Injects the database session into the FastAPI route and closes it at the end."""
  db = SessionLocal()
  try:
    yield db
  finally:
    db.close()