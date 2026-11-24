import logging
import os
from logging.handlers import RotatingFileHandler
from pathlib import Path

FMT = "%(asctime)s %(levelname)-7s [%(service)s] %(name)s: %(message)s"
_configured: set[str] = set()


class _WithService(logging.Filter):
    def __init__(self, service: str):
        super().__init__()
        self.service = service

    def filter(self, log_record: logging.LogRecord) -> bool:
        log_record.service = self.service
        return True


def logs_folder() -> Path:
    return Path(os.environ.get("MUFASA_LOG_DIR", Path(__file__).resolve().parents[1] / "logs"))


def configure_logging(service: str) -> None:
    if service in _configured:
        return
    _configured.add(service)
    level = getattr(logging, os.environ.get("MUFASA_LOG_LEVEL", "INFO").upper(), logging.INFO)
    root = logging.getLogger()
    root.setLevel(level)
    for h in list(root.handlers):
        root.removeHandler(h)
    fmt = logging.Formatter(FMT)
    filter_value = _WithService(service)
    console = logging.StreamHandler()
    console.setFormatter(fmt)
    console.addFilter(filter_value)
    root.addHandler(console)
    try:
        folder = logs_folder()
        folder.mkdir(parents=True, exist_ok=True)
        file = RotatingFileHandler(folder / f"{service}.log", maxBytes=5_000_000, backupCount=5, encoding="utf-8")
        file.setFormatter(fmt)
        file.addFilter(filter_value)
        root.addHandler(file)
    except OSError:
        logging.getLogger("mufasa.log_record").warning("no permission to write logs to a file; console only")
