#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if ! docker info >/dev/null 2>&1; then
  echo "Docker is not open, so MUFASA is already stopped."; exit 0
fi
docker compose stop
echo "[ok] MUFASA stopped. To start it again: ./start_mufasa.sh"
