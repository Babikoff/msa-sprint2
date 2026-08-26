# Task 4 - отчёт о проделанной работе

## Запуск сервиса booking-service в minikube

### 1.Запуск Kubernetes cluster ###
minikube start --driver=docker

### 2.Проверка статуса Minikube ###
*minikube status*
**Ожидается:**
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

### 3. Билд docker image ###
**Ожидается:**
docker build -t booking-service:1.0.1 ./booking-service
[+] Building 4.4s (12/12) FINISHED                                                                                                             docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                                                                           0.1s
 => => transferring dockerfile: 860B                                                                                                                           0.0s
 => [internal] load metadata for docker.io/library/golang:1.21-alpine                                                                                          1.5s
 => [internal] load .dockerignore                                                                                                                              0.0s
 => => transferring context: 2B                                                                                                                                0.0s
 => [1/7] FROM docker.io/library/golang:1.21-alpine@sha256:2414035b086e3c42b99654c8b26e6f5b1b1598080d65fd03c7f499552ff4dc94                                    0.2s
 => => resolve docker.io/library/golang:1.21-alpine@sha256:2414035b086e3c42b99654c8b26e6f5b1b1598080d65fd03c7f499552ff4dc94                                    0.2s
 => [internal] load build context                                                                                                                              0.0s
 => => transferring context: 61B                                                                                                                               0.0s
 => CACHED [2/7] RUN apk add --no-cache curl                                                                                                                   0.0s
 => CACHED [3/7] WORKDIR /app                                                                                                                                  0.0s
 => CACHED [4/7] COPY main.go .                                                                                                                                0.0s
 => CACHED [5/7] COPY check-dns.sh .                                                                                                                           0.0s
 => CACHED [6/7] RUN chmod +x check-dns.sh                                                                                                                     0.0s
 => CACHED [7/7] RUN go build -o booking-service main.go                                                                                                       0.0s
 => exporting to image                                                                                                                                         2.1s
 => => exporting layers                                                                                                                                        0.0s
 => => exporting manifest sha256:965ec39024063f3c762b361faf1579e9e6083036e0a5771d8094486826d4ad15                                                              0.0s
 => => exporting config sha256:57635c675b445377284800444d5936996e521f2c769e747e8afc729a3e190cdf                                                                0.0s
 => => exporting attestation manifest sha256:9733b00d1cd2ac3785a233ab9047955fd51d6e9718f1cef81e94b172d37fac49                                                  0.1s
 => => exporting manifest list sha256:1518c85d1ba91eca21e3e5d2edc67636a1d21215dd06e718c30d2b4b43a61b6c                                                         0.1s
 => => naming to docker.io/library/booking-service:1.0.1                                                                                                       0.0s
 => => unpacking to docker.io/library/booking-service:1.0.1   

### 4. Загрузка image в Minikube ###
minikube image load booking-service:1.0.1
**Ожидается:**
Отсутствие вывода при отсутствии ошибок.

### 5. Накат базовой конфигурации ###
*helm upgrade --install booking-service ./helm/booking-service --values ./helm/booking-service/values.yaml*
**Ожидается:**
helm upgrade --install booking-service ./helm/booking-service --values ./helm/booking-service/values-prod.yaml
Release "booking-service" has been upgraded. Happy Helming!
NAME: booking-service
LAST DEPLOYED: Wed Aug 26 16:21:08 2026
NAMESPACE: default
STATUS: deployed
REVISION: 14
DESCRIPTION: Upgrade complete
TEST SUITE: None


#### 5.1. Накат конфигурации STAGING ####
helm upgrade --install booking-service ./helm/booking-service --values ./helm/booking-service/values-staging.yaml

**ИЛИ**

#### 5.2. Накат конфигурации PROD ####
*helm upgrade --install booking-service ./helm/booking-service --values ./helm/booking-service/values-prod.yaml*
**Ожидается:**
Release "booking-service" has been upgraded. Happy Helming!
NAME: booking-service
LAST DEPLOYED: Wed Aug 26 19:42:29 2026
NAMESPACE: default
STATUS: deployed
REVISION: 15
DESCRIPTION: Upgrade complete
TEST SUITE: None

**Проверка того, то запущены 3 реплики сервиса:**
*kubectl get pods,svc*
**Ожидается:**
NAME                                   READY   STATUS              RESTARTS   AGE
pod/booking-service-5686488498-kglmm   1/1     Running             0          4h10m
pod/booking-service-5686488498-lm2tq   1/1     Running             0          68s
pod/booking-service-5686488498-trtdn   1/1     Running             0          68s
pod/booking-service-686f8d4749-ns44n   0/1     ErrImageNeverPull   0          68s

NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/booking-service   ClusterIP   10.99.82.142   <none>        80/TCP    30h
service/kubernetes        ClusterIP   10.96.0.1      <none>        443/TCP   42h

### 6.Включение проброса порта контейнера 8080 на машину хоста ###
*kubectl port-forward svc/booking-service 8080:80*
**Ожидается:**
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080


**Далее всё делаем в новом терминале:**

### 7. Проверка статуса ###

**Проверка pods/services**
*& 'C:\Program Files\Git\bin\bash.exe' .\check-status.sh*
**Ожидается:**

▶️ Checking booking-service deployment...
NAME                               READY   STATUS    RESTARTS   AGE
booking-service-5686488498-kglmm   1/1     Running   0          3h24m

▶️ Checking service...
NAME              TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
booking-service   ClusterIP   10.99.82.142   <none>        80/TCP    29h

▶️ Helm release:
booking-service default         14              2026-08-26 16:21:08.3281014 +0500 +05   deployed        booking-service-0.1.0   1.0        

▶️ Port-forward to test service locally:
  kubectl port-forward svc/booking-service 8080:80
  Then in another terminal:
    curl http://localhost:8080/ping

▶️ Quick curl (if port-forward already running):
pong✅ Reachable

### 8.Проверка резолвинга DNS в кластере ###
*& 'C:\Program Files\Git\bin\bash.exe' .\check-dns.sh*

**Ожидается:**
▶️ Running in-cluster DNS test...
pongpod "dns-test" deleted from default namespace
✅ Success

### 9. Ping сервиса ###
Ping с помощью **curl**:
curl http://localhost:8080/ping            
**Ожидается:**
pong

### 10. Проверка включения/отключения опции ENABLE_FEATURE_X в STAGING/PROD: ###
**Развёртываем службу скрипатами в кластер с опцией STAGING:**
*& 'C:\Program Files\Git\bin\bash.exe' .\deploy-staging.sh*

ИЛИ

*./deploy-staging.bat*

В отдельном терминале запускаем проброс протов:
*kubectl port-forward svc/booking-service 8080:80*

**Проверка**
*curl http://localhost:8080/feature*

**Ожидается:**
*Feature X is enabled!*


#### 10.2. Проверка отключения опции ####
**Развёртываем службу скрипатами в кластер с опцией PROD:**
*& 'C:\Program Files\Git\bin\bash.exe' .\deploy-prod.sh*

ИЛИ

*./deploy-prod.bat*

В отдельном терминале запускаем проброс протов:
*kubectl port-forward svc/booking-service 8080:80*

**Проверка**
*curl http://localhost:8080/feature*

**Ожидается:**
*404 page not found*
