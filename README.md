# DevOps CI/CD AWS Platform

An end-to-end DevOps showcase: a small Spring Boot service shipped through a **GitHub Actions CI/CD pipeline**, containerized with **Docker**, deployed to **AWS ECS Fargate behind an ALB** with **Terraform**, with equivalent **Kubernetes manifests** for an EKS/self-managed cluster path.

By Maruthi Pawan Avula.

## What's in here

```
.
├── app/                    Sample Spring Boot 3 service (the workload)
│   ├── src/main/java/com/maruthi/platform
│   └── src/test/java/com/maruthi/platform
├── Dockerfile              Multi-stage build for the sample service
├── .github/workflows/
│   ├── ci.yml              Build + test + Docker image on every push/PR
│   └── cd.yml              Deploy stub: ECR push + ECS rollout (manual, OIDC)
├── terraform/              AWS infrastructure as code
│   ├── versions.tf         Provider + Terraform version pins
│   ├── variables.tf        Region, sizing, CIDR, counts
│   ├── main.tf             VPC, ECR, ALB, ECS Fargate, IAM, logging
│   └── outputs.tf          ALB URL, ECR URL, cluster/service names
└── k8s/                    Kubernetes manifests for the same service
    ├── deployment.yaml     2 replicas, probes, resource limits
    ├── service.yaml        ClusterIP service
    ├── ingress.yaml        Ingress (nginx / AWS ALB controller notes)
    └── hpa.yaml            CPU/memory autoscaling (2–6 replicas)
```

## The pipeline, end to end

```
  git push ──▶ GitHub Actions CI ──▶ mvn verify (build + tests)
                    │
                    └──▶ Docker image build (Buildx, layer cache)
                                │
  manual trigger ──▶ GitHub Actions CD (stub)
                    │  AWS credentials via OIDC — no stored keys
                    ├──▶ push image to Amazon ECR (scan on push)
                    └──▶ roll out new ECS Fargate task revision
                                │
                    ┌───────────▼────────────┐
                    │  ALB (public, HTTP)    │
                    │     │ health check:    │
                    │     │ /actuator/health │
                    │  ECS Fargate tasks     │
                    │  (private subnets,     │
                    │   logs → CloudWatch)   │
                    └────────────────────────┘
```

1. **CI (`.github/workflows/ci.yml`)** runs on every push and pull request to `main`: JDK 17 setup with Maven caching, `mvn verify` (compile + tests, reports uploaded as artifacts), then a Docker image build for pushes to `main`.
2. **CD (`.github/workflows/cd.yml`)** is a deliberately gated stub: manual `workflow_dispatch`, a `production` GitHub Environment for approvals, AWS auth through **OIDC** (no long-lived access keys), ECR login + push, and a placeholder deploy step showing where the ECS task-definition rollout goes. Fill in the repository secrets/vars listed at the top of the file to activate it.
3. **Terraform (`terraform/`)** provisions everything the CD pipeline deploys to:
   - VPC-lite: one VPC, public subnets for the ALB, private subnets for tasks, single NAT gateway (dev-friendly cost)
   - ECR repository with scan-on-push
   - ALB + target group with an Actuator health check
   - ECS Fargate cluster/service, task definition, execution IAM role, CloudWatch log group
   - Security groups chained ALB → tasks (tasks accept traffic only from the ALB)
4. **Kubernetes (`k8s/`)** runs the same container on any cluster: Deployment with readiness/liveness probes against Spring Boot Actuator probe endpoints, a ClusterIP Service, an Ingress, and an HPA.

## Quick start

### Run the sample service locally

```bash
cd app && mvn spring-boot:run
# or with Docker, from the repo root:
docker build -t sample-service .
docker run -p 8080:8080 sample-service
curl http://localhost:8080/
```

### Provision the AWS infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Outputs include the ALB URL and the ECR repository URL. Push an image, then update the service:

```bash
aws ecr get-login-password | docker login --username AWS --password-stdin <ecr-repo-url>
docker tag sample-service:latest <ecr-repo-url>:latest
docker push <ecr-repo-url>:latest
aws ecs update-service --cluster <cluster> --service <service> --force-new-deployment
```

### Run on Kubernetes

```bash
kubectl apply -f k8s/
kubectl get pods,svc,ingress,hpa
```

## Notes

- The Terraform default sizing (256 CPU / 512 MiB, 2 tasks) is dev-oriented; tune `task_cpu`, `task_memory`, and `desired_count` in `variables.tf`.
- Remote state (S3 + DynamoDB lock) is shown commented out in `versions.tf` — enable it before collaborating.
- The CD workflow never runs unattended: it is manual-dispatch only and stops at a placeholder until real AWS values are configured.
