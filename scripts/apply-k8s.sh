#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Build da imagem local da API (mecaniqa-backend:latest)"
docker build -t mecaniqa-backend:latest ./backend

if command -v minikube >/dev/null 2>&1 && minikube status >/dev/null 2>&1; then
  echo "==> Carregando imagem no Minikube"
  minikube image load mecaniqa-backend:latest
elif command -v kind >/dev/null 2>&1; then
  CLUSTER_NAME="$(kind get clusters 2>/dev/null | head -n1 || true)"
  if [[ -n "${CLUSTER_NAME}" ]]; then
    echo "==> Carregando imagem no kind (${CLUSTER_NAME})"
    kind load docker-image mecaniqa-backend:latest --name "${CLUSTER_NAME}"
  fi
fi

echo "==> Aplicando manifests Kubernetes (Deployments + Services)"
kubectl apply -k k8s/

echo "==> Aguardando rollouts"
kubectl -n mecaniqa rollout status deployment/mysql --timeout=180s
kubectl -n mecaniqa rollout status deployment/redis --timeout=180s
kubectl -n mecaniqa rollout status deployment/backend --timeout=180s

echo "==> Estado atual do namespace mecaniqa"
kubectl -n mecaniqa get deploy,svc,pods,pvc

echo
echo "Próximo passo: inspecionar com K9s"
echo "  k9s -n mecaniqa"
echo
echo "Para validar a API (NodePort):"
echo "  NODE_PORT=\$(kubectl -n mecaniqa get svc backend -o jsonpath='{.spec.ports[0].nodePort}')"
echo "  curl http://localhost:\${NODE_PORT}/api/status"
echo "  curl http://localhost:\${NODE_PORT}/api/dependencies"
