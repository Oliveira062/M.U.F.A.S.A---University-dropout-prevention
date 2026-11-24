from fastapi import FastAPI
from app.api import chatbot
from app.database import models
from app.database.database import Base, engine

# Creates the tables in SQLite if they do not exist yet
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="MUFASA",
    description=(
        "University Monitoring of Attendance, Activities, Health and"
        " Learning"
    ),
    version="0.1.0",
)

# Register the chatbot router
app.include_router(chatbot.router)


@app.get("/")
def initial_page():
  return {"message": "MUFASA API running. Go to /docs to test the chatbot."}


@app.get("/health")
def check_health():
  return {"status": "up", "system": "MUFASA"}