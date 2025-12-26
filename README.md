# Craftista - Cloud-Native Origami Platform

A production-ready, polyglot microservices application deployed on AWS EKS with full CI/CD, monitoring, and GitOps capabilities.

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![AWS](https://img.shields.io/badge/AWS-EKS-orange.svg)](https://aws.amazon.com/eks/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30-326CE5.svg)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-orange.svg)](https://argoproj.github.io/cd/)

## 📋 Table of Contents

- [About the Project](#about-the-project)
- [Architecture](#architecture)
- [Services](#services)
- [Infrastructure](#infrastructure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Deployment](#deployment)
- [Monitoring](#monitoring)
- [Development](#development)
- [Project Structure](#project-structure)
- [Contributing](#contributing)

## 🎯 About the Project

Craftista is a cloud-native web platform dedicated to the art of origami. Built as a learning platform by [School of Devops](https://schoolofdevops.com), it demonstrates modern DevOps practices including:

- **Polyglot Microservices**: Python (Flask), Node.js (Express), Go, Java (Spring Boot)
- **Container Orchestration**: Kubernetes on AWS EKS
- **Infrastructure as Code**: Terraform for AWS resources
- **GitOps**: ArgoCD for declarative deployments
- **Observability**: Prometheus, Grafana, Blackbox Exporter
- **CI/CD**: GitHub Actions with OIDC authentication

### Key Features

🎨 **Origami Showcase** - Browse a curated collection of origami art  
🗳️ **Voting System** - Vote for your favorite creations  
⭐ **Daily Recommendations** - AI-powered origami suggestions  
📊 **Real-time Metrics** - Full observability stack

## 🏗️ Architecture

![Craftista Architecture](docs/Craftista-Architecture-SchoolofDevops-CC-BY-NC-SA4.0.jpg)

### Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Container Orchestration** | AWS EKS 1.30 | Kubernetes cluster management |
| **Container Registry** | Amazon ECR | Docker image storage |
| **Infrastructure** | Terraform | Infrastructure as Code |
| **GitOps** | ArgoCD | Continuous deployment |
| **Monitoring** | Prometheus + Grafana | Metrics and visualization |
| **Health Checks** | Blackbox Exporter | HTTP endpoint monitoring |
| **Package Management** | Helm 3 | Kubernetes application packaging |
| **Networking** | AWS VPC + ALB | Network isolation and load balancing |

## 🎯 Services

### Frontend Service (Node.js + Express)
- **Port**: 80
- **Purpose**: Web UI, routing, service orchestration
- **Features**: Server-side rendering with EJS templates
- **Health Check**: `GET /`

### Catalogue Service (Python + Flask)
- **Port**: 5000
- **Purpose**: Product catalog management
- **Endpoints**: `/api/products`
- **Database**: In-memory JSON storage

### Voting Service (Java + Spring Boot)
- **Port**: 8080
- **Purpose**: User voting system
- **Endpoints**: `/api/origamis`
- **Features**: Spring Data JPA, REST API

### Recommendation Service (Go)
- **Port**: 8080
- **Purpose**: AI-powered recommendations
- **Features**: Lightweight Go HTTP server

## 🛠️ Infrastructure

### AWS Resources (Terraform)

```
infra/
├── main.tf              # EKS cluster configuration
├── ecr.tf               # Container registry
├── iam_github_oidc.tf   # GitHub Actions OIDC
├── alb_controller_irsa.tf # ALB Controller IAM
└── variables.tf         # Configuration variables
```

**Created Resources**:
- EKS Cluster (t3.medium nodes, 2-4 auto-scaling)
- VPC with public/private subnets across 3 AZs
- ECR repositories for all services
- IAM roles for GitHub Actions and AWS Load Balancer Controller
- KMS encryption for EKS secrets

### Kubernetes Resources

```yaml
# Namespaces
- craftista        # Application workloads
- argocd          # GitOps controller
- monitoring      # Prometheus stack
- kube-system     # System components
```

## 📦 Prerequisites

### Required Tools
- **AWS CLI** (v2.x) - AWS command line interface
- **kubectl** (v1.30+) - Kubernetes CLI
- **terraform** (v1.5+) - Infrastructure provisioning
- **helm** (v3.19+) - Kubernetes package manager
- **docker** - Container runtime

### AWS Account Setup
1. AWS account with admin access
2. AWS SSO configured (or IAM user credentials)
3. S3 bucket for Terraform state (created in bootstrap)

## 🚀 Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/kenzo213/craftista.git
cd craftista
```

### 2. Bootstrap Infrastructure

```bash
cd infra/bootstrap
terraform init
terraform apply  # Creates S3 bucket for state
```

### 3. Deploy Infrastructure

```bash
cd ../
terraform init
terraform apply  # Creates EKS, ECR, IAM roles
```

### 4. Configure kubectl

```bash
aws eks update-kubeconfig --region us-east-1 --name craftista-dev
kubectl get nodes  # Verify cluster access
```

### 5. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 6. Deploy Application

```bash
# Using Helm
helm upgrade --install craftista helm/craftista -n craftista --create-namespace

# Or using ArgoCD
kubectl apply -f argocd/craftista-app.yaml
```

## 📊 Monitoring

### Prometheus + Grafana Stack

```bash
# Install kube-prometheus-stack
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace

# Apply monitoring configs
kubectl apply -f monitoring/blackbox-exporter.yaml
kubectl apply -f monitoring/craftista-alerts.yaml

# Access Grafana
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3001:80
# Username: admin
# Password: prom-operator
```

### Available Metrics

- `probe_success` - HTTP endpoint health (0=down, 1=up)
- `probe_duration_seconds` - Response time
- `probe_http_status_code` - HTTP status codes

### Alerts Configured

| Alert | Severity | Condition | Duration |
|-------|----------|-----------|----------|
| CraftistServiceDown | Critical | probe_success == 0 | 2 minutes |
| CraftistServiceSlowResponse | Warning | duration > 5s | 5 minutes |
| CraftistServiceHttpError | Warning | status >= 400 | 2 minutes |

## 👨‍💻 Development

### Local Development

```bash
# Run service locally
cd services/catalogue
python app.py

# Run with Docker Compose
docker-compose up
```

### Build and Push Images

```bash
# Configure AWS ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 132410971191.dkr.ecr.us-east-1.amazonaws.com

# Build and push
cd services/catalogue
docker build -t craftista-catalogue:latest .
docker tag craftista-catalogue:latest 132410971191.dkr.ecr.us-east-1.amazonaws.com/craftista-catalogue:sha-2305f20
docker push 132410971191.dkr.ecr.us-east-1.amazonaws.com/craftista-catalogue:sha-2305f20
```

### Deploy to Different Environments

```bash
# Development
helm upgrade --install craftista helm/craftista \
  --values helm/craftista/values-dev.yaml \
  -n craftista-dev --create-namespace

# Staging
helm upgrade --install craftista helm/craftista \
  --values helm/craftista/values-staging.yaml \
  -n craftista-staging --create-namespace

# Production
helm upgrade --install craftista helm/craftista \
  --values helm/craftista/values-prod.yaml \
  -n craftista --create-namespace
```

## 📁 Project Structure

```
craftista/
├── argocd/                      # ArgoCD application manifests
│   └── craftista-app.yaml
├── helm/                        # Helm charts
│   └── craftista/
│       ├── Chart.yaml
│       ├── values.yaml          # Default values
│       ├── values-dev.yaml      # Dev overrides
│       ├── values-staging.yaml  # Staging overrides
│       ├── values-prod.yaml     # Prod overrides
│       └── templates/           # Kubernetes manifests
├── infra/                       # Terraform infrastructure
│   ├── main.tf                  # EKS cluster
│   ├── ecr.tf                   # Container registry
│   ├── iam_github_oidc.tf       # GitHub Actions IAM
│   ├── alb_controller_irsa.tf   # ALB Controller IAM
│   ├── backend.tf               # Terraform backend
│   └── bootstrap/               # Initial S3 setup
├── k8s/                         # Raw Kubernetes manifests
│   ├── base/                    # Base deployments
│   └── ingress.yaml
├── monitoring/                  # Monitoring configuration
│   ├── blackbox-exporter.yaml   # HTTP probes
│   └── craftista-alerts.yaml    # Prometheus alerts
├── services/                    # Microservices source code
│   ├── catalogue/               # Python/Flask
│   ├── frontend/                # Node.js/Express
│   ├── recommendation/          # Go
│   └── voting/                  # Java/Spring Boot
└── docs/                        # Documentation
```

## 🔧 Configuration

### Environment-Specific Settings

Each environment has its own values file with different configurations:

| Setting | Dev | Staging | Prod |
|---------|-----|---------|------|
| Replicas | 1 | 2 | 3 |
| CPU Request | 100m | 200m | 500m |
| Memory Request | 128Mi | 256Mi | 512Mi |
| CPU Limit | 200m | 500m | 1000m |
| Memory Limit | 256Mi | 512Mi | 1Gi |

### Service Configuration Files

Each service has a `config.json`:

```json
{
  "environment": "production",
  "port": 5000,
  "catalogue_url": "http://catalogue:5000",
  "recommendation_url": "http://recommendation:8080",
  "voting_url": "http://voting:8080"
}
```

## 🐛 Troubleshooting

### Common Issues

#### EKS Cluster Access Denied

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name craftista-dev

# Verify AWS credentials
aws sts get-caller-identity
```

#### ArgoCD Showing "Unknown" Sync Status

**Cause**: Helm charts not committed to Git repository

**Solution**:
```bash
git add helm/
git commit -m "Add Helm charts"
git push origin main
kubectl delete application craftista -n argocd
kubectl apply -f argocd/craftista-app.yaml
```

#### Pods Stuck in Pending State

```bash
# Check node status
kubectl get nodes

# Describe pod for events
kubectl describe pod <pod-name> -n craftista

# Check cluster autoscaler logs
kubectl logs -n kube-system -l app=cluster-autoscaler
```

#### ImagePullBackOff Error

```bash
# Verify ECR authentication
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 132410971191.dkr.ecr.us-east-1.amazonaws.com

# Check if image exists
aws ecr describe-images --repository-name craftista-catalogue --region us-east-1
```

#### ALB Controller IAM Permissions Error

**Error**: `AccessDenied: User is not authorized to perform: elasticloadbalancing:AddTags`

**Solution**: Update IAM policy in [infra/iam/alb_iam_policy.json](infra/iam/alb_iam_policy.json) to remove restrictive conditions on AddTags action, then:

```bash
cd infra
terraform apply
```

#### Port Forwarding Conflicts

```bash
# Find process using port
lsof -i :8080

# Kill process
kill -9 <PID>

# Use alternative port
kubectl port-forward svc/frontend -n craftista 9000:80
```

### Monitoring Issues

#### Prometheus Not Scraping Metrics

```bash
# Verify ServiceMonitor in correct namespace
kubectl get servicemonitor -n monitoring

# Check Prometheus targets
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090
# Open http://localhost:9090/targets
```

#### Blackbox Exporter Probes Failing

```bash
# Check probe status
kubectl get probe -n monitoring

# View blackbox exporter logs
kubectl logs -n monitoring -l app=blackbox-exporter

# Test endpoint manually
kubectl run test --rm -it --image=curlimages/curl -- curl http://catalogue.craftista.svc.cluster.local:5000/api/products
```

### Debugging Commands

```bash
# View all resources in namespace
kubectl get all -n craftista

# Check logs for specific service
kubectl logs -n craftista -l app=catalogue --tail=100

# Execute commands in pod
kubectl exec -it -n craftista <pod-name> -- /bin/sh

# View events
kubectl get events -n craftista --sort-by='.lastTimestamp'

# Check resource usage
kubectl top nodes
kubectl top pods -n craftista
```

## 🔐 Security Considerations

- **IAM Roles**: Use IRSA (IAM Roles for Service Accounts) instead of static credentials
- **Secrets Management**: Store sensitive data in Kubernetes Secrets or AWS Secrets Manager
- **Network Policies**: Implement network policies to restrict pod-to-pod communication
- **Image Scanning**: Enable ECR image scanning for vulnerabilities
- **Pod Security**: Use Pod Security Standards (restricted profile recommended)

## 📈 Performance Tuning

### Horizontal Pod Autoscaling

```bash
# Create HPA for catalogue service
kubectl autoscale deployment catalogue \
  --cpu-percent=50 \
  --min=2 \
  --max=10 \
  -n craftista
```

### Resource Optimization

Monitor resource usage and adjust requests/limits:

```bash
# View resource usage
kubectl top pods -n craftista --containers

# Update values file
vim helm/craftista/values-prod.yaml
```

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Workflow

1. Make changes in `services/` directory
2. Build and test locally
3. Update Helm chart version in `helm/craftista/Chart.yaml`
4. Commit and push changes
5. ArgoCD will automatically sync and deploy

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **School of Devops** - Original project creators
- **AWS** - Cloud infrastructure
- **CNCF** - Kubernetes, Prometheus, ArgoCD, and ecosystem tools
- **Community** - Contributors and supporters

## 📞 Support

- **GitHub Issues**: [Report bugs or request features](https://github.com/kenzo213/craftista/issues)
- **Documentation**: [Additional docs](docs/)
- **School of Devops**: [Training and courses](https://schoolofdevops.com)

## 🗺️ Roadmap

- [ ] Add Istio service mesh
- [ ] Implement distributed tracing with Jaeger
- [ ] Add database backends (MongoDB, PostgreSQL)
- [ ] Implement CI/CD with GitHub Actions
- [ ] Add canary deployments
- [ ] Implement horizontal pod autoscaling
- [ ] Add logging aggregation with ELK stack
- [ ] Create disaster recovery procedures

---

**Built with ❤️ by [School of Devops](https://schoolofdevops.com)**

*For the complete learning experience and guided projects, visit [School of Devops](https://schoolofdevops.com)*

## For Developers and DevOps Enthusiasts
Craftista serves as a perfect sandbox for developers and DevOps practitioners. The microservices architecture of the application makes it an ideal candidate for experimenting with containerization, orchestration, CI/CD pipelines, and cloud-native technologies. It's designed to be a hands-on project for learning and implementing DevOps best practices.

---
## 15 Project Ides to build using this Application Repo 

Here are 10 basic projects you could build with it that would make you a Real Devops Engineer
  1.  Containerize with Docker: Write Dockerfiles for each of the services, and a docker compose to run it as a micro services application stack to automate dev environments.  
  2.  Build CI Pipeline : Build a complete CI Pipeline using Jenkins, GitHub Actions, Azure Devops etc.  
  3.  Deploy to Kubernetes : Write kubernetes manifests to create Deployments, Services, PVCs, ConfigMaps, Statefulsets and more  
  4.  Package with Helm : Write helm charts to templatize the kubernetes manifests and prepare to deploy in different environments  
  5.  Blue/Green and Canary Releases with ArgoCD/GitOps: Setup releases strategies with Argo Rollouts Combined with ArgoCD and integrate with CI Pipeline created in 3. to setup a complete CI/CD workflow.  
  6.  Setup Observability : Setup monitoring with Prometheus and Grafana (Integrate this for automated CD with rollbacks using Argo), Setup log management with ELS/EFK Stack or Splunk.
  7.  Build a DevSecOps Pipeline: Create a DevSecOps Pipeline by adding SCA, SAST, Image Scanning, DAST, Compliance Scans, Kubernetes Scans etc. and more at each stage.
  8.  Design and Build Cloud Infra : Build Scalable, Hight Available, Resilience, Fault Tolerance Cloud Infra to host this app.
  9.  Write Terraform Templating : Automate the infra designed in project 8. Use Terragrunt on top for multi environment configurations.  
  10.  Python Scripts for Automation : Automate ad-hoc tasks using python scripts.

and if you want to take it to the next level here are 5 Advanced Projects:

  1. Deploy on EKS/AKS: Build EKS/AKS Cluster and deploy this app with helm packages you created earlier.
  2. Implement Service Mesh: Setup advanced observability, traffic management and shaping, mutual TLS, client retries and more with Istio.
  3. AIOps: On top of Observability, incorporate Machine Learning models, Falco and Argo Workflow for automated monitoring, incident response and mitigation.
  4. SRE: Implement SLIs, SLOs, SLAs on top of the project 6 and setup Site Reliability Engineering practices.  
  5. Chaos Engineering : Use LitmusChaos to test resilience of your infra built on Cloud with Kubernetes and Istio.

## Contributing
While we have attempted to make it a Perfect Learning App, and have got many things right, its still a work in progress. As we see more useful features from the perspective of learning Devops, we will continue to improve upon this work. We welcome contributions from the community! Whether you're an origami artist wanting to showcase your work, a developer interested in microservices, or just someone enthusiastic about the devops learning projects, your contributions are valuable. Check out our contributing guidelines(to be added) for more information. While we are writing the guidelines, feel free send us a pull request when you have something interesting to add.  

## Attribution
This project is released under the Apache 2.0 License. If you use, modify, or distribute this project, you must retain the original license and give proper credit to the authors. Please include a reference to the original repository and authors: [[GitHub Repository URL](https://github.com/craftista)].

## License
Craftista is open-sourced under the Apache License 2.0.

## How to Get started with Devops Mastery ? 
While you could take this application code to design and build devops projects yourself, you may benefit by going through a holistic, structured program which combines Courses and Labs with Projects, AI Strategies, Community, Coaching and Certification Prep. Thats what [Devops Mastery System](https://schoolofdevops.com/#why) created by Gourav Shah, Founder at [School of Devops](https://schoolofdevops.com/) is all about. Gourav is a leading Corporate Trainer on Devops, has conducted 450+ workshops for Top companies of the world, has been a course creator with Linux Foundation, is published on eDX and has tailor built this learning app himself. Get started with your journey to upScale your Career and experience the AI Assisted, Project Centric Devops Mastery System and by enrolling into our [Starter Kit](https://schoolofdevops.com/#starterkit). 






