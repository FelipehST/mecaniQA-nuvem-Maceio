# MecaniQA - OAT 1 - Nuvem

Repositório da OAT 1 da disciplina de Nuvem do Programa de Trainee 2026.2.

## Equipe

**Time:** Maceió  
**Unidade:** Itabuna

### Integrantes

- Felipe Souza Teixeira da Silva
- Fernando Gustavo Barbosa Santos
- Gustavo dos Santos Nobre
- Joadson Breno Neves Pereira
- João Paulo Rosa Batista

## Objetivo

Conteinerizar e orquestrar o ecossistema da MecaniQA, utilizando:

- Java 17 com Spring Boot;
- MySQL;
- Redis;
- Docker;
- Docker Compose;
- Kubernetes;
- Terraform.

## Estrutura do projeto

```text
mecaniQA-nuvem-maceio/
├── backend/
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/
├── mysql/
│   ├── Dockerfile
│   └── init.sql
├── redis/
│   ├── Dockerfile
│   └── redis.conf
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── mysql-pvc.yaml
│   ├── redis-pvc.yaml
│   ├── mysql.yaml
│   ├── redis.yaml
│   └── backend.yaml
├── terraform/
│   ├── versions.tf
│   ├── variables.tf
│   ├── main.tf
│   └── outputs.tf
├── docker-compose.yml
├── .gitignore
└── README.md
```

## Docker Compose

Na raiz do projeto, execute:

```bash
docker compose up --build
```

A aplicação ficará disponível em:

```text
http://localhost:8080/api/status
```

Para verificar a comunicação com MySQL e Redis:

```text
http://localhost:8080/api/dependencies
```

Para encerrar:

```bash
docker compose down
```

Para encerrar e remover os volumes:

```bash
docker compose down -v
```

## Kubernetes

Construa a imagem do backend:

```bash
docker build -t mecaniqa-backend:latest ./backend
```

Se estiver usando Minikube:

```bash
minikube image load mecaniqa-backend:latest
```

Aplique os manifestos:

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/mysql-pvc.yaml
kubectl apply -f k8s/redis-pvc.yaml
kubectl apply -f k8s/mysql.yaml
kubectl apply -f k8s/redis.yaml
kubectl apply -f k8s/backend.yaml
```

Verifique os recursos:

```bash
kubectl get all -n mecaniqa
kubectl get pvc -n mecaniqa
```

Com Minikube, acesse o backend usando:

```bash
minikube service backend -n mecaniqa
```

## Terraform

Entre na pasta:

```bash
cd terraform
```

Execute:

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

## Tecnologias

- Java 17
- Spring Boot
- Maven
- MySQL
- Redis
- Docker
- Docker Compose
- Kubernetes
- Terraform

## Entrega

O projeto deve ser entregue na branch `main` do repositório:

```text
mecaniQA-nuvem-maceio
```

Professor no GitHub:

```text
lasilva
```

> As credenciais presentes neste projeto são destinadas apenas ao ambiente acadêmico/local.
