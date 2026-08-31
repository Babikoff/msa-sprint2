@echo off
setlocal
REM ============================================================
REM start-istio.bat — установка Istio в Minikube и деплой Booking (v1+v2).
REM Путь к istioctl можно переопределить: set ISTIOCTL=C:\...\istioctl.exe
REM ============================================================

if "%ISTIOCTL%"=="" set "ISTIOCTL=C:\Istio\istio-1.30.4\bin\istioctl.exe"

@REM 1) Запуск кластера Kubernetes
@REM Подготовка кластера Kubernetes
minikube start --memory=4096 --cpus=2

@REM Обновить kubeconfig на актуальный endpoint
minikube update-context

@REM Предварительная подгрузка образа ingress-nginx на случай таймаута при вызове "istioctl install"
@REM minikube ssh docker pull registry.k8s.io/ingress-nginx/controller:v1.14.3

@REM 2) Проверка istioctl
if not exist "%ISTIOCTL%" (
    echo ERROR: istioctl не найден: %ISTIOCTL%
    echo Скачайте Windows-сборку Istio (istio-x.win-amd64.zip) и задайте ISTIOCTL.
    exit /b 1
)
"%ISTIOCTL%" version --remote=false

@REM 3) Установка Istio, если namespace istio-system ещё не создан.
@REM Эта команда развёртывает Istio в вашем кластере Kubernetes
@REM с использованием демопрофиля, который включает все основные компоненты Istio.
kubectl get namespace istio-system >nul 2>&1
if %errorlevel%==0 (
    echo Istio уже установлен, пропускаем install.
) else (
    "%ISTIOCTL%" install --set profile=demo -y
)

@REM 4) Включите автоматическую вставку sidecar-прокси для namespace,
@REM где будут работать микросервисы Booking
kubectl label namespace default istio-injection=enabled --overwrite

@REM 5) Сборка и загрузка образа booking-service в Minikube
docker build -t booking-service:latest ./booking-service
minikube image load booking-service:latest

@REM 6) Применение манифестов Booking
@REM Применение конфигурации развёртывает микросервис Booking в кластере Kubernetes
@REM с автоматической вставкой Sidecar-прокси для управления трафиком.
kubectl apply -f booking-service-deployment.yaml
kubectl apply -f booking-service-service.yaml

@REM Развёртываем НОВУЮ ВЕРСИЮ микросервиса Booking в кластере Kubernetes
kubectl apply -f booking-service-deployment-v2.yaml

@REM Применение конфигурации трафика настраивает маршрутизацию и балансировку нагрузки
@REM (канареечный Release 90/10, фича-флаг, retries, Circuit Breaking)
kubectl apply -f booking-service-traffic.yaml

@REM Фича-флаг через EnvoyFilter (заголовок X-Feature-Enabled)
kubectl apply -f booking-service-envoy-filter.yaml

@REM 7) Проверка
kubectl rollout status deployment/booking-v1 --timeout=120s
kubectl rollout status deployment/booking-v2 --timeout=120s
kubectl get pods -n istio-system
kubectl get pods -l app=booking
kubectl get virtualservice,destinationrule,envoyfilter

echo.
echo ============================================================
echo Деплой завершён. 
echo ============================================================

echo Для проверки локально открывает порт 8080 и запускаем тестовые скрипты из другого терминала
kubectl port-forward svc/booking 8080:80
endlocal