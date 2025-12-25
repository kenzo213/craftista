# Craftista Helm Chart

This Helm chart deploys the Craftista microservices application to Kubernetes.

## Chart Structure

```
helm/craftista/
├── Chart.yaml                      # Chart metadata
├── values.yaml                     # Default values
├── values-dev.yaml                 # Development environment overrides
├── values-staging.yaml             # Staging environment overrides
├── values-prod.yaml                # Production environment overrides
└── templates/
    ├── catalogue-deploy.yaml       # Catalogue deployment
    ├── catalogue-svc.yaml          # Catalogue service
    ├── frontend-deploy.yaml        # Frontend deployment
    ├── frontend-svc.yaml           # Frontend service
    ├── recommendation-deploy.yaml  # Recommendation deployment
    ├── recommendation-svc.yaml     # Recommendation service
    ├── voting-deploy.yaml          # Voting deployment
    └── voting-svc.yaml             # Voting service
```

## Prerequisites

- Kubernetes cluster (EKS)
- Helm 3.x installed
- kubectl configured to access your cluster
- Namespace created (e.g., `kubectl create namespace craftista-dev`)

## Installation

### Deploy to Development

```bash
helm install craftista ./helm/craftista \
  --values ./helm/craftista/values-dev.yaml \
  --namespace craftista-dev \
  --create-namespace
```

### Deploy to Staging

```bash
helm install craftista ./helm/craftista \
  --values ./helm/craftista/values-staging.yaml \
  --namespace craftista-staging \
  --create-namespace
```

### Deploy to Production

```bash
helm install craftista ./helm/craftista \
  --values ./helm/craftista/values-prod.yaml \
  --namespace craftista \
  --create-namespace
```

## Upgrade

To upgrade an existing deployment:

```bash
# Development
helm upgrade craftista ./helm/craftista \
  --values ./helm/craftista/values-dev.yaml \
  --namespace craftista-dev

# Staging
helm upgrade craftista ./helm/craftista \
  --values ./helm/craftista/values-staging.yaml \
  --namespace craftista-staging

# Production
helm upgrade craftista ./helm/craftista \
  --values ./helm/craftista/values-prod.yaml \
  --namespace craftista
```

## Override Values

You can override specific values at deployment time:

```bash
helm install craftista ./helm/craftista \
  --values ./helm/craftista/values-dev.yaml \
  --set imageTag=sha-abc123 \
  --set catalogue.replicaCount=3 \
  --namespace craftista-dev
```

## Uninstall

```bash
helm uninstall craftista --namespace craftista-dev
```

## Customization

### Environment-Specific Configuration

Each environment has its own values file:

- **values-dev.yaml**: 1 replica per service, development mode
- **values-staging.yaml**: 2 replicas per service, staging mode
- **values-prod.yaml**: 3 replicas per service, production mode with resource limits

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `namespace` | Kubernetes namespace | `craftista` |
| `imageRegistry` | ECR registry URL | `132410971191.dkr.ecr.us-east-1.amazonaws.com` |
| `imageTag` | Image tag for all services | `sha-2305f20` |
| `<service>.enabled` | Enable/disable service | `true` |
| `<service>.replicaCount` | Number of replicas | `2` |
| `<service>.image.tag` | Override image tag per service | (uses global imageTag) |
| `<service>.env` | Environment variables | varies by service |
| `<service>.resources` | Resource requests/limits | `{}` |

## Validation

After deployment, verify all pods are running:

```bash
kubectl get pods -n craftista-dev
```

Check services:

```bash
kubectl get svc -n craftista-dev
```

## Template Rendering

To see the rendered templates without deploying:

```bash
helm template craftista ./helm/craftista \
  --values ./helm/craftista/values-dev.yaml
```
