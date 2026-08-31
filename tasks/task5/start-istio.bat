@echo off
rem Switch console to UTF-8 for Cyrillics.
chcp 65001 >nul
setlocal
REM ============================================================
REM start-istio.bat — установка Istio в Minikube и деплой Booking (v1+v2).
REM Путь к istioctl можно переопределить: set ISTIOCTL=C:\...\istioctl.exe
REM ============================================================

if "%ISTIOCTL%"=="" set "ISTIOCTL=C:\Istio\istio-1.30.4\bin\istioctl.exe"

echo 1) Запуск кластера Kubernetes
echo Подготовка кластера Kubernetes
minikube start --memory=4096 --cpus=2

echo Обновить kubeconfig на актуальный endpoint
minikube update-context

echo Предварительная подгрузка образа ingress-nginx на случай таймаута при вызове "istioctl install"
echo minikube ssh docker pull registry.k8s.io/ingress-nginx/controller:v1.14.3

echo 2) Проверка istioctl
if not exist "%ISTIOCTL%" (
    echo ERROR: istioctl не найден: %ISTIOCTL%
    echo Скачайте Windows-сборку Istio ^(istio-x.win-amd64.zip^) и задайте ISTIOCTL.
    exit /b 1
)
"%ISTIOCTL%" version --remote=false

echo 3) Установка Istio, если namespace istio-system ещё не создан.
echo Эта команда развёртывает Istio в вашем кластере Kubernetes
echo с использованием демопрофиля, который включает все основные компоненты Istio.
kubectl get namespace istio-system >nul 2>&1
if %errorlevel%==0 (
    echo Istio уже установлен, пропускаем install.
) else (
    "%ISTIOCTL%" install --set profile=demo -y
)

echo 4) Включите автоматическую вставку sidecar-прокси для namespace,
echo где будут работать микросервисы Booking
kubectl label namespace default istio-injection=enabled --overwrite

echo 5) Сборка и загрузка образа booking-service в Minikube
docker build -t booking-service:latest ./booking-service
minikube image load booking-service:latest

echo 6) Применение манифестов Booking
echo Применение конфигурации развёртывает микросервис Booking в кластере Kubernetes
echo с автоматической вставкой Sidecar-прокси для управления трафиком.
kubectl apply -f booking-service-deployment.yaml
kubectl apply -f booking-service-service.yaml

echo Развёртываем НОВУЮ ВЕРСИЮ (v2) микросервиса Booking в кластере Kubernetes
kubectl apply -f booking-service-deployment-v2.yaml

echo Применение конфигурации трафика настраивает маршрутизацию и балансировку нагрузки
echo (канареечный Release 90/10, фича-флаг, retries, Circuit Breaking)
kubectl apply -f booking-service-traffic.yaml

echo Фича-флаг через EnvoyFilter (заголовок X-Feature-Enabled)
kubectl apply -f booking-service-envoy-filter.yaml

echo 7) Проверка
kubectl rollout status deployment/booking-v1 --timeout=120s
kubectl rollout status deployment/booking-v2 --timeout=120s
kubectl get pods -n istio-system
kubectl get pods -l app=booking
kubectl get virtualservice,destinationrule,envoyfilter

echo.
echo ============================================================
echo Деплой завершён. 
echo ============================================================

echo Если нужно вызвать сервис напрямую (curl http://localhost:8080/ping), 
echo то можно открыть порт командой: "kubectl port-forward svc/booking 8080:80" 
echo и выполнять тестовые запросы к сервису из другого терминала.
endlocal