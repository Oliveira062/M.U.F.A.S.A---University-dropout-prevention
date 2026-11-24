#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "=== MUFASA: starting the system ==="
command -v docker >/dev/null || { echo "[ERROR] Docker not found. See docs/06_LOCAL_DOCKER_USE.md"; exit 1; }

if ! docker info >/dev/null 2>&1; then
  echo "Opening Docker..."
  if [ "$(uname)" = "Darwin" ]; then open -a Docker || true; fi
  for _ in $(seq 36); do
    docker info >/dev/null 2>&1 && break
    echo "Waiting for Docker to finish opening..."; sleep 5
  done
  docker info >/dev/null 2>&1 || { echo "[ERROR] Docker did not respond. Open Docker and run this again."; exit 1; }
fi
echo "[ok] Docker is up."

echo "Preparing the version in this folder..."
docker build -q -t mufasa:1.1.0 . >/dev/null
if [ ! -f .env ]; then
  echo "First time on this computer: creating the .env file..."
  docker run --rm -u root -v "$PWD:/app" mufasa:1.1.0 python -m scripts.configure --docker
fi
echo "[ok] Configuration (.env) found."
if [ -f groq.env ]; then
  docker run --rm -u root -v "$PWD:/app" mufasa:1.1.0 python -m scripts.configure --keys
fi

docker compose up -d

echo "Waiting for the dashboard to be ready..."
for _ in $(seq 120); do
  if curl -sf -o /dev/null http://127.0.0.1:8501/_stcore/health; then
    echo "[ok] MUFASA is up: dashboard http://127.0.0.1:8501 | API http://127.0.0.1:8000/docs"
    if command -v open >/dev/null; then open http://127.0.0.1:8501
    elif command -v xdg-open >/dev/null; then xdg-open http://127.0.0.1:8501 >/dev/null 2>&1 || true; fi
    echo "To stop: ./stop_mufasa.sh (the data is kept)."
    exit 0
  fi
  sleep 5
done
echo "[ERROR] The dashboard did not respond. See: docker compose ps -a  and  docker compose logs dashboard"
exit 1
