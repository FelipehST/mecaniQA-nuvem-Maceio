# Relatório da Sessão — 09/09/2026

**Problema:** Docker, Docker-Compose, K8s  
**Data:** 09/09/2026  
**Piloto:** Fernando Gustavo B. Santos  
**Copilotos:** Gustavo Nobre, Jonatan de Souza Ferreira  
**QA:** Joadson Breno  
**Arquiteto:** João Paulo Rosa Batista  
**Scrum Master:** Felipe Souza

## Contexto do Dia

O Docker Compose resolveu o ambiente local, mas possui limitações críticas de resiliência e auto-healing para a produção. Com a infraestrutura em nuvem provisionada, precisamos traduzir o sistema para a linguagem declarativa do Kubernetes, separando a computação da lógica de roteamento.

## Brainstorm Guiado

### Unidade Básica e Estado Desejado

**Pergunta:** Por que não devemos criar Pods de forma isolada, e como a declaração de um Deployment garante que a API da MecâniQA Tech se recupere automaticamente em caso de falhas?

**Decisão da Equipe:**

Não criamos Pods isolados (`kind: Pod`) porque eles não possuem controlador. Se o processo Java morre, o Pod some e ninguém o recria.

Declaramos a API como **Deployment** (`k8s/backend.yaml`) com `replicas: 2`. O ReplicaSet mantém o estado desejado e recria Pods que falham. A recuperação automática é reforçada por:

- `livenessProbe` em `/api/status` — reinicia container travado
- `readinessProbe` em `/api/status` — remove do Service Pods ainda não prontos

MySQL e Redis também ficam em Deployment (`replicas: 1`), não em Pod avulso, para manter reconciliação e probes.

### Estratégia de Exposição (Services)

**Pergunta:** Por que o MySQL e o Redis devem utilizar ClusterIP, enquanto a API Java precisa de um LoadBalancer ou NodePort para ser acessada pelas oficinas clientes?

**Decisão da Equipe:**

- **MySQL e Redis → ClusterIP:** tráfego apenas interno. DNS estável (`mysql`, `redis`) sem expor porta no nó. As oficinas não devem acessar banco/cache.
- **API → NodePort:** entrada externa para as oficinas no cluster da disciplina. LoadBalancer fica como evolução natural em nuvem com balanceador do provedor.

Comunicação da API com dependências:

- `jdbc:mysql://mysql:3306/mecaniqa`
- `REDIS_HOST=redis` / `REDIS_PORT=6379` (ConfigMap)

## Entrega do Encontro 3

### Objetivo prático

Realizar a gestão de Pods, Deployments e Services no cluster, utilizando manifestos YAML nativos.

### Artefatos

| Artefato | Papel |
|----------|--------|
| `k8s/backend.yaml` | Deployment + Service NodePort da API |
| `k8s/mysql.yaml` | Deployment + Service ClusterIP do MySQL |
| `k8s/redis.yaml` | Deployment + Service ClusterIP do Redis |
| `k8s/configmap.yaml` / `secret.yaml` | Configuração e credenciais |
| `k8s/*-pvc.yaml` | Persistência MySQL/Redis |
| `k8s/kustomization.yaml` | Aplicação ordenada dos manifests |
| `scripts/apply-k8s.sh` | Build da imagem + `kubectl apply -k` + validação |

### Passo a passo (piloto / copiloto)

1. Converter Compose → Deployments/Services em `k8s/`
2. Aplicar no cluster: `./scripts/apply-k8s.sh` ou `kubectl apply -k k8s/`
3. Inspecionar com K9s: `k9s -n mecaniqa`
4. Investigar `CrashLoopBackOff` via describe/logs no K9s

### Validação QA

| # | Cenário | Comando / ação | Esperado |
|---|---------|----------------|----------|
| 1 | Deployments no ar | `kubectl -n mecaniqa get deploy` | backend, mysql, redis Ready |
| 2 | Serviços corretos | `kubectl -n mecaniqa get svc` | mysql/redis ClusterIP; backend NodePort |
| 3 | API externa | `curl` no NodePort `/api/status` | `"status":"UP"` |
| 4 | Dependências | `curl` `/api/dependencies` | mysql/redis `UP` |
| 5 | Auto-healing | deletar 1 Pod do backend | ReplicaSet recria |
| 6 | K9s | `k9s -n mecaniqa` | sem CrashLoopBackOff |
