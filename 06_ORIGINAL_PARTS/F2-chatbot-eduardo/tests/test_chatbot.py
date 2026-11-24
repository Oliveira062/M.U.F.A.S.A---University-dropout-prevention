from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_main_menu():
  """Tests whether sending 'menu' returns the main options."""
  response = client.post(
      "/chatbot/messages", json={"user_id": 1, "text": "menu"}
  )
  assert response.status_code == 200
  data = response.json()
  assert data["intent"] == "MAIN_MENU"
  assert "options" in data


def test_attendance_query_with_acento():
  """Tests the attendance query with accents and capital letters."""
  response = client.post(
      "/chatbot/messages",
      json={"user_id": 1, "text": "What is my attendance in Mathematics?"},
  )
  assert response.status_code == 200
  data = response.json()
  assert data["intent"] == "SUBJECT_ATTENDANCE_QUERY"
  assert "88%" in data["answer"]


def test_calculation_grade_query():
  """Tests the grade query for Calculus."""
  response = client.post(
      "/chatbot/messages", json={"user_id": 1, "text": "calculus grade"}
  )
  assert response.status_code == 200
  data = response.json()
  assert data["intent"] == "SUBJECT_GRADE_QUERY"
  assert "5.5" in data["answer"]


def test_not_reconhecida_message():
  """Tests the fallback for messages the bot does not under under understand."""
  response = client.post(
      "/chatbot/messages", json={"user_id": 1, "text": "abracadabra 123"}
  )
  assert response.status_code == 200
  data = response.json()
  assert data["intent"] == "NOT_RECOGNIZED"


def test_get_user_history():
  """Tests retrieving the conversation history saved in the database."""
  client.post(
      "/chatbot/messages",
      json={"user_id": 99, "text": "main menu"},
  )

  response = client.get("/chatbot/history/99")
  assert response.status_code == 200

  history = response.json()
  assert len(history) > 0
  assert history[0]["user_id"] == 99
  assert history[0]["user_message"] == "main menu"
  assert history[0]["intent"] == "MAIN_MENU"