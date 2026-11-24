import logging
import os
from logging.handlers import RotatingFileHandler
from pathlib import Path

log = logging.getLogger("mufasa.dashboard")

if not log.handlers:
    log.setLevel(getattr(logging, os.environ.get("MUFASA_LOG_LEVEL", "INFO").upper(), logging.INFO))
    log.propagate = False
    fmt = logging.Formatter("%(asctime)s %(levelname)-7s [dashboard] %(name)s: %(message)s")
    console = logging.StreamHandler()
    console.setFormatter(fmt)
    log.addHandler(console)
    try:
        folder = Path(os.environ.get("MUFASA_LOG_DIR", Path(__file__).resolve().parents[1] / "logs"))
        folder.mkdir(parents=True, exist_ok=True)
        file = RotatingFileHandler(folder / "dashboard.log", maxBytes=5_000_000, backupCount=5, encoding="utf-8")
        file.setFormatter(fmt)
        log.addHandler(file)
    except OSError:
        log.warning("no permission to write logs to a file; console only")
