from app.chatbot.chat_database import get_chat_engine
from app.chatbot.chat_routes import router_chat
from app.factory import create_service

from app.log_record import configure_logging

configure_logging("chat")


def create_app():
    return create_service("chat", "MUFASA Chat", (router_chat,), get_chat_engine, life_signal=True)


app = create_app()
