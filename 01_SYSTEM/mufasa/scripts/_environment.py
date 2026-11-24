import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load_env(path: Path | None = None) -> dict:
    path = path or ROOT / ".env"
    read = {}
    if path.exists():
        for row in path.read_text(encoding="utf-8").splitlines():
            row = row.strip()
            if not row or row.startswith("#") or "=" not in row:
                continue
            name, value = row.split("=", 1)
            value = value.strip()
            if len(value) >= 2 and value[0] == value[-1] and value[0] in "'\"":
                value = value[1:-1]
            read[name.strip()] = value
    for name, value in read.items():
        os.environ.setdefault(name, value)
    return read
