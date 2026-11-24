from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict
from pydantic import BaseModel


class InputMessage(BaseModel):
  user_id: int
  text: str
  profile: str = "student"  # Options: "student", "teacher", "admin"


class InputMessage(BaseModel):
  user_id: int
  text: str


class ChatbotAnswer(BaseModel):
  intent: str
  answer: str
  options: Optional[List[str]] = None


class ItemHistory(BaseModel):
  model_config = ConfigDict(from_attributes=True)

  id: int
  user_id: int
  user_message: str
  bot_answer: str
  intent: str
  time_data: datetime