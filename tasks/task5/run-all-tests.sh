#!/bin/bash
#
# run-all-tests.sh - прогон всех проверок task5 (check-istio / check-feature-flag /
#                   check-canary / check-fallback) после start-istio.bat.
#
# ВАЖНО: для корректной работы тестов нужно, чтобы в mesh существовал под
# curl-client (kubectl apply -f test-client.yaml). start-istio.bat его НЕ создаёт,
# поэтому скрипт применяет манифест сам и ждёт готовности подов.

set -e
cd "$(dirname "$0")"
RESULTS=results
mkdir -p "$RESULTS"

echo "=== [0] Применяем тест-клиент curl-client (из mesh) ==="
kubectl apply -f test-client.yaml

echo
echo "=== Ожидание готовности подов ==="
kubectl wait --for=condition=ready pod -l app=booking --timeout=180s
kubectl wait --for=condition=ready pod -l app=curl-client --timeout=120s
kubectl get pods -l app=booking

run_check() {
    name=$1
    echo
    echo "=============================================="
    echo "  >>> $name"
    echo "=============================================="
    bash "$name.sh" | tee "$RESULTS/$name.txt"
}

run_check check-istio
run_check check-feature-flag
run_check check-canary
run_check check-fallback

echo
echo "=============================================="
echo " Все проверки завершены. Текущее состояние:"
kubectl get pods -l app=booking
echo " Результаты сохранены в $RESULTS/"
echo "=============================================="