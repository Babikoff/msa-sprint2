@REM Подготовка кластера Kubernetes
minikube start

@REM Предварительная подгрузка образа ingress-nginx на случай таймаута при вызове "istioctl install"
@REM minikube ssh docker pull registry.k8s.io/ingress-nginx/controller:v1.14.3

@REM Установка Istio в кластер.
@REM Эта команда развёртывает Istio в вашем кластере Kubernetes 
@REM с использованием демопрофиля, который включает все основные компоненты Istio. 
@REM Это упрощённый способ начать работу с Istio и протестировать его функциональность.
istioctl install --set profile=demo -y

kubectl label namespace default istio-injection=enabled

@REM Для маршрутизации трафика на 127.0.0.1 выполнить "minikube tunnel" в отдельном терминале

@REM Проверка установки
@REM Эта команда отображает все поды в пространстве имён istio-system, 
@REM где находятся компоненты Istio. 
@REM Все поды должны быть в состоянии Running или Completed.
kubectl get pods -n istio-system

@REM Включите автоматическую вставку sidecar-прокси для namespace, 
@REM где будут работать микросервисы Booking
kubectl label namespace default istio-injection=enabled

@REM Применение конфигурации
@REM Применение конфигурации развёртывает микросервис Booking в кластере Kubernetes 
@REM с автоматической вставкой Sidecar-прокси для управления трафиком.
kubectl apply -f booking-service-deployment.yaml

@REM Применение конфигурации трафика настраивает маршрутизацию и балансировку нагрузки 
@REM для микросервисов Booking, обеспечивая гибкость и контроль над трафиком.
kubectl apply -f booking-service-traffic.yaml


@REM Настройка мониторинга

@REM Установка Prometheus и Grafana
@REM Убедитесь, что Prometheus и Grafana установлены вместе с Istio:
kubectl get pods -n istio-system

@REM Настройка метрик и дашбордов
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}') 3000:3000

@REM Далее, используйте дашборды Grafana для мониторинга производительности и 
@REM состояния микросервисов

@REM Трассировка запросов
@REM Убедитесь, что Jaeger установлен вместе с Istio:
kubectl get pods -n istio-system

@REM Откройте интерфейс Jaeger для просмотра трассировки запросов:
kubectl -n istio-system port-forward $(kubectl -n istio-system get pod -l app=jaeger -o jsonpath='{.items[0].metadata.name}') 16686:16686
@REM Используйте Jaeger для анализа пути прохождения запросов через микросервисы

@REM Настройка Service Discovery с Istio

@REM Проверка работоспособности Service Discovery
@REM Вы должны увидеть сервис kube-dns или coredns
kubectl get svc -n kube-system

@REM Применение конфигурации для создания сервисов:
kubectl apply -f booking-service-service.yaml

@REM Применение конфигурации
@REM Развёртываем НОВУЮ ВЕРСИЮ микросервиса Booking в кластере Kubernetes 
kubectl apply -f booking-service-deployment-v2.yaml

@REM Разделение трафика
kubectl apply -f booking-service-traffic-split.yaml

@REM TODO: создать и применить envoy filter, зависящий от X-FEATURE-ENABLED