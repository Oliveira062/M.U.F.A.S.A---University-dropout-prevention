import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

from scripts._environment import ROOT, load_env

PARTS = {
    "api": [sys.executable, "-m", "uvicorn", "app.main:app", "--host", "127.0.0.1", "--port", "8000"],
    "chat": [sys.executable, "-m", "uvicorn", "app.main_chat:app", "--host", "127.0.0.1", "--port", "8001"],
    "calculation": [sys.executable, "-m", "app.calculation_service"],
    "dashboard": [sys.executable, "-m", "streamlit", "run", "app.py"],
}
FOLDER = {"dashboard": ROOT / "dashboard"}
REQUIRED = {"api": ["DATABASE_URL", "JWT_SECRET"], "chat": ["CHAT_DATABASE_URL", "JWT_SECRET"],
                "calculation": ["CALCULATION_DATABASE_URL"], "dashboard": []}


class Part:
    def __init__(self, name: str, logs: Path):
        self.name, self.logs = name, logs
        self.proc: subprocess.Popen | None = None
        self.wait = 2.0
        self.next_attempt = 0.0
        self.started_at = 0.0
        self.restarts = 0

    def start(self):
        output = open(self.logs / f"{self.name}.console.log", "a", encoding="utf-8")
        output.write(f"\n===== start {time.strftime('%d/%m/%Y %H:%M:%S')} =====\n")
        output.flush()
        self.proc = subprocess.Popen(PARTS[self.name], cwd=FOLDER.get(self.name, ROOT), stdout=output,
                                     stderr=subprocess.STDOUT, env=os.environ.copy())
        self.started_at = time.monotonic()
        print(f"[{time.strftime('%H:%M:%S')}] {self.name:8} started (pid {self.proc.pid})")

    def check(self):
        if self.proc is None or self.proc.poll() is None:
            if self.proc and time.monotonic() - self.started_at > 120:
                self.wait = 2.0
            return
        now = time.monotonic()
        if self.next_attempt == 0.0:
            code = self.proc.returncode
            print(f"[{time.strftime('%H:%M:%S')}] {self.name:8} STOPPED (code {code}); new attempt in "
                  f"{self.wait:.0f} s. Details: logs/{self.name}.console.log")
            self.next_attempt = now + self.wait
            self.wait = min(60.0, self.wait * 2)
        elif now >= self.next_attempt:
            self.next_attempt = 0.0
            self.restarts += 1
            self.start()

    def stop(self):
        if self.proc and self.proc.poll() is None:
            self.proc.terminate()
            try:
                self.proc.wait(timeout=10)
            except subprocess.TimeoutExpired:
                self.proc.kill()


def main() -> int:
    load_env()
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--only", help="comma-separated list: api,chat,calculation,dashboard")
    ap.add_argument("--without-chat", action="store_true")
    args = ap.parse_args()
    names = args.only.split(",") if args.only else list(PARTS)
    if args.without_chat and "chat" in names:
        names.remove("chat")
    unknown = set(names) - set(PARTS)
    if unknown:
        print(f"Unknown parts: {', '.join(unknown)}", file=sys.stderr)
        return 2
    missing = sorted({v for n in names for v in REQUIRED[n] if not os.environ.get(v)})
    if missing:
        print("Variables missing in .env: " + ", ".join(missing) + ". See .env.example.", file=sys.stderr)
        return 2
    os.environ.setdefault("MUFASA_API_URL", "http://127.0.0.1:8000")
    os.environ.setdefault("MUFASA_CHAT_URL", "http://127.0.0.1:8001")
    logs = Path(os.environ.get("MUFASA_LOG_DIR", ROOT / "logs"))
    logs.mkdir(parents=True, exist_ok=True)

    parts = [Part(n, logs) for n in names]
    for p in parts:
        p.start()
    if "dashboard" in names:
        print("\nDashboard: http://127.0.0.1:8501   (Ctrl+C to stop)")
        print("Check everything: python -m scripts.diagnostics\n")
    try:
        while True:
            for p in parts:
                p.check()
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nStopping...")
    finally:
        for p in parts:
            p.stop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
