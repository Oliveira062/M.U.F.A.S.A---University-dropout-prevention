from datetime import datetime
from sqlalchemy import Column, DateTime, Float, Integer, String
from app.database.database import Base


class Subject(Base):
  __tablename__ = "subjects"

  id = Column(Integer, primary_key=True, index=True)
  name = Column(
      String, unique=True, index=True
  )  # Normalized name e.g.: "mathematics"
  exibicao_name = Column(String)  # Formatted name e.g.: "Mathematics"
  attendance = Column(String)  # E.g.: "88%"
  absences = Column(Integer, default=0)
  grade = Column(Float, default=0.0)


class MessageHistory(Base):
  __tablename__ = "messages_history"

  id = Column(Integer, primary_key=True, index=True)
  user_id = Column(Integer, index=True)
  user_message = Column(String, nullable=False)
  bot_answer = Column(String, nullable=False)
  intent = Column(String, nullable=False)
  time_data = Column(DateTime, default=datetime.utcnow)