#!/bin/bash
#
# check-status.sh — сводный статус деплоя Booking (v1/v2) и Istio-ресурсов.

set -e

echo "▶️ Checking booking deployments..."
kubectl get deploy -l app=booking

echo
echo "▶️ Checking booking pods (2/2 = есть sidecar Envoy)..."
kubectl get pods -l app=booking

echo
echo "▶️ Checking service..."
kubectl get svc booking || echo "(No service found)"

echo
echo "▶️ Istio traffic config (VirtualService / DestinationRule / EnvoyFilter)..."
kubectl get virtualservice,destinationrule,envoyfilter

echo
echo "▶️ Port-forward to test service locally:"
echo "  kubectl port-forward svc/booking 8080:80"
echo "  Then in another terminal:"
echo "    curl http://localhost:8080/ping"

echo
echo "▶️ Quick curl (if port-forward already running):"
curl --fail -s http://localhost:8080/ping && echo " ✅ Reachable" || echo " ❌ Not responding"
