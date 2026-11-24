@echo off
chcp 65001 >nul
title MUFASA - stop
cd /d "%~dp0"

echo.
echo === MUFASA: stopping the system ===
docker info >nul 2>&1
if errorlevel 1 (
  echo Docker Desktop is not open, so MUFASA is already stopped.
  timeout /t 10
  exit /b 0
)
docker compose stop
echo.
echo [ok] MUFASA stopped. To start it again, double-click START_MUFASA.bat.
timeout /t 10
exit /b 0
