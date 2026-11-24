@echo off
chcp 65001 >nul
setlocal
title MUFASA - start
cd /d "%~dp0"

echo.
echo === MUFASA: starting the system ===
echo.

where docker >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Docker was not found. Install Docker Desktop: see docs\06_LOCAL_DOCKER_USE.md
  goto :error_end
)

docker info >nul 2>&1
if not errorlevel 1 goto :docker_ok
echo Opening Docker Desktop...
if exist "%ProgramFiles%\Docker\Docker\Docker Desktop.exe" start "" "%ProgramFiles%\Docker\Docker\Docker Desktop.exe"
set /a attempts=0
:wait_docker
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if not errorlevel 1 goto :docker_ok
set /a attempts+=1
if %attempts% geq 36 (
  echo [ERROR] Docker Desktop did not respond in 3 minutes. Open Docker Desktop, wait until it turns green and run this file again.
  goto :error_end
)
echo Waiting for Docker Desktop to finish opening...
goto :wait_docker
:docker_ok
echo [ok] Docker is up.

echo Preparing the version in this folder (the first time takes a few minutes)...
docker build -q -t mufasa:1.1.0 . >nul
if errorlevel 1 (
  docker build -t mufasa:1.1.0 .
  goto :error_end
)

if exist ".env" goto :env_ok
echo First time on this computer: creating the .env file...
docker run --rm -u root -v "%cd%:/app" mufasa:1.1.0 python -m scripts.configure --docker
if errorlevel 1 goto :error_end
:env_ok
echo [ok] Configuration (.env) found.

if exist "groq.env" docker run --rm -u root -v "%cd%:/app" mufasa:1.1.0 python -m scripts.configure --keys

docker compose up -d
if errorlevel 1 (
  echo [ERROR] Could not start the services. See: docker compose ps -a  and  docker compose logs build_database
  goto :error_end
)

echo Waiting for the dashboard to be ready...
set /a attempts=0
:wait_dashboard
curl -s -f -o nul http://127.0.0.1:8501/_stcore/health >nul 2>&1
if not errorlevel 1 goto :dashboard_ok
set /a attempts+=1
if %attempts% geq 120 (
  echo [ERROR] The dashboard did not respond. See: docker compose ps -a  and  docker compose logs dashboard
  goto :error_end
)
timeout /t 5 /nobreak >nul
goto :wait_dashboard
:dashboard_ok

echo.
echo [ok] MUFASA is up:
echo      Dashboard  http://127.0.0.1:8501
echo      API        http://127.0.0.1:8000/docs
echo.
echo To stop it, double-click STOP_MUFASA.bat. The data is kept.
start "" http://127.0.0.1:8501
timeout /t 10
exit /b 0

:error_end
echo.
pause
exit /b 1
