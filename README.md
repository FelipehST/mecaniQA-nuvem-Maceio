# MecaniQA - OAT 1 - Nuvem

Repositório da OAT 1 da disciplina de Nuvem.

## Equipe

**Time:** Maceió  
**Unidade:** Itabuna

### Integrantes

- Felipe Souza Teixeira da Silva
- Fernando Gustavo Barbosa Santos
- Gustavo dos Santos Nobre
- Joadson Breno Neves Pereira
- João Paulo Rosa Batista

## Arquitetura

| Camada | Docker Compose | Kubernetes |
|--------|----------------|------------|
| API Java | serviço `backend` + porta `8080:8080` | Deployment `backend` + Service **NodePort** |
| MySQL | serviço `mysql` (rede interna) | Deployment `mysql` + Service **ClusterIP** |
| Redis | serviço `redis` (rede interna) | Deployment `redis` + Service **ClusterIP** |

Persistência: volumes no Compose; PVCs (`mysql-pvc`, `redis-pvc`) no Kubernetes.

## Ambiente local (Compose)

```bash
docker compose up --build -d
curl http://localhost:8080/api/status
curl http://localhost:8080/api/dependencies
```

## Encontro 3 — Kubernetes (Deployments + Services)

### 1. Converter Compose → YAML

Manifests em `k8s/`:

- Deployments: `backend.yaml`, `mysql.yaml`, `redis.yaml`
- Services: ClusterIP (MySQL/Redis) e NodePort (API)
- ConfigMap, Secret, PVCs e Namespace

Aplicação ordenada via `k8s/kustomization.yaml`.

### 2. Aplicar no cluster

Pré-requisitos: `kubectl` apontando para o cluster, Docker e (opcional) Minikube/kind + K9s.

```bash
chmod +x scripts/apply-k8s.sh
./scripts/apply-k8s.sh
```

Equivalente manual:

```bash
docker build -t mecaniqa-backend:latest ./backend
# Minikube: minikube image load mecaniqa-backend:latest
# kind:     kind load docker-image mecaniqa-backend:latest

kubectl apply -k k8s/
kubectl -n mecaniqa get deploy,svc,pods
```

Validar a API pelo NodePort:

```bash
NODE_PORT=$(kubectl -n mecaniqa get svc backend -o jsonpath='{.spec.ports[0].nodePort}')
curl "http://localhost:${NODE_PORT}/api/status"
curl "http://localhost:${NODE_PORT}/api/dependencies"
```

### 3. Inspecionar com K9s (CrashLoopBackOff)

```bash
k9s -n mecaniqa
```

No K9s:

1. Abrir `deployments` / `pods`
2. Se um Pod estiver vermelho ou em `CrashLoopBackOff`, usar `d` (describe) e `l` (logs)
3. Causas comuns: imagem `mecaniqa-backend:latest` ausente no cluster, MySQL/Redis ainda não Ready, Secret/ConfigMap incorretos

## Documentação da sessão

Ver [docs/relatorio-sessao-09-09-2026.md](docs/relatorio-sessao-09-09-2026.md) (brainstorm + entrega do encontro 3).
