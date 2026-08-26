@echo off
setlocal EnableExtensions

REM ============================================================
REM  deploy-prod.bat
REM  Full deploy/redeploy of booking-service into Minikube using
REM  the PROD values (ENABLE_FEATURE_X=false, replicaCount=3).
REM  Mirrors the CI/CD flow: build -> smoke test -> load image
REM  -> helm upgrade --install.
REM ============================================================
cd /d "%~dp0"

set "IMAGE_NAME=booking-service"
set "RELEASE_NAME=booking-service"
set "VALUES_FILE=./helm/booking-service/values-prod.yaml"
set "CONTAINER=test-booking-prod"
set "TEST_PORT=8082"

REM --- Unique image tag (timestamp) unless IMAGE_TAG is provided ---
if defined IMAGE_TAG (
    set "FINAL_TAG=%IMAGE_TAG%"
) else (
    for /f "delims=" %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmmss"') do set "FINAL_TAG=local-%%i"
)

echo ============================================================
echo  Deploying %RELEASE_NAME% [PROD]
echo  Image : %IMAGE_NAME%:%FINAL_TAG%
echo  Values: %VALUES_FILE%
echo ============================================================

REM ---------- [1/5] Build the image ----------
echo.
echo [1/5] Building image %IMAGE_NAME%:%FINAL_TAG% ...
docker build -t %IMAGE_NAME%:%FINAL_TAG% ./booking-service
if errorlevel 1 goto :error

REM ---------- [2/5] Smoke-test /ping ----------
echo.
echo [2/5] Smoke-testing /ping ...
docker rm -f %CONTAINER% >nul 2>&1
docker run -d --name %CONTAINER% -p %TEST_PORT%:8080 %IMAGE_NAME%:%FINAL_TAG%
if errorlevel 1 goto :error
timeout /t 2 /nobreak >nul
curl -f http://localhost:%TEST_PORT%/ping >nul 2>&1
if errorlevel 1 goto :error_smoke
echo       OK: /ping returned pong
docker rm -f %CONTAINER% >nul 2>&1

REM ---------- [3/5] Load image into Minikube ----------
echo.
echo [3/5] Loading image into Minikube ...
minikube image load %IMAGE_NAME%:%FINAL_TAG%
if errorlevel 1 goto :error

REM ---------- [4/5] Helm deploy / redeploy ----------
echo.
echo [4/5] helm upgrade --install (prod values) ...
helm upgrade --install %RELEASE_NAME% ./helm/booking-service ^
    -f %VALUES_FILE% ^
    --set image.tag=%FINAL_TAG% ^
    --set image.pullPolicy=IfNotPresent
if errorlevel 1 goto :error

REM ---------- [5/5] Wait for rollout ----------
echo.
echo [5/5] Waiting for rollout ...
kubectl rollout status deployment/%RELEASE_NAME%
if errorlevel 1 goto :error

echo.
echo [OK] PROD deployment (ENABLE_FEATURE_X=false) successful.
kubectl get pods -l app=%RELEASE_NAME%
exit /b 0

:error_smoke
echo.
echo [ERROR] Smoke test failed: /ping did not return pong.
docker rm -f %CONTAINER% >nul 2>&1
goto :error

:error
echo.
echo [ERROR] Deployment failed. See output above.
exit /b 1