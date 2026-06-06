#!/usr/bin/env bash
# Regenerates content and deploys to the edge cluster.
# Usage: ./deploy.sh
set -euo pipefail
cd "$(dirname "$0")"

./generate.sh

kubectl apply -f k8s/manifests.yaml

kubectl create configmap go-vanity-content -n klarlabs \
  --from-file=public/ --dry-run=client -o yaml | kubectl apply -f -

kubectl create configmap go-vanity-nginx -n klarlabs \
  --from-file=default.conf=nginx-default.conf --dry-run=client -o yaml | kubectl apply -f -

kubectl rollout restart deployment/go-vanity -n klarlabs
kubectl rollout status deployment/go-vanity -n klarlabs --timeout=120s
