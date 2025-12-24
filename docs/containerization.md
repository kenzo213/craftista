# Containerization Guide

## Overview

This document describes the containerization strategy and setup for the Craftista demo application, a microservices-based origami platform.

## Architecture

The application consists of 5 containerized services orchestrated via Docker Compose:

```
services/
├── api/           # Catalogue service (Python/Flask)
├── frontend/      # Web interface (Node.js/Express)
├── worker/        # Recommendation service (Go/Gin)
├── voting/        # Voting service (Java/Spring Boot)
└── database/      # PostgreSQL database
```

## Service Details

### Catalogue Service (API)
- **Technology**: Python 3.12 + Flask + Gunicorn
- **Port**: 5000
- **Database**: PostgreSQL
- **Health Check**: Socket connection test
- **Build**: Multi-stage Dockerfile with Python slim image

### Frontend Service
- **Technology**: Node.js 18 + Express + EJS
- **Port**: 3000 (exposed as 80)
- **Purpose**: Web UI and API gateway
- **Build**: Node.js Alpine image

### Recommendation Service (Worker)
- **Technology**: Go 1.19 + Gin framework
- **Port**: 8080
- **Purpose**: Provides origami recommendations
- **Build**: Multi-stage Go build

### Voting Service
- **Technology**: Java 17 + Spring Boot
- **Port**: 8080 (exposed as 8081)
- **Database**: H2 (in-memory)
- **Purpose**: User voting functionality
- **Build**: Multi-stage Maven build

### Database Service
- **Technology**: PostgreSQL 16.2 Alpine
- **Port**: 5432 (internal)
- **Purpose**: Persistent data storage
- **Volume**: Named volume for data persistence

## Docker Configuration

### Build Strategy
- **Multi-stage builds** for all services to minimize image size
- **Alpine Linux** base images where possible
- **Distroless** or **scratch** images for Go service
- **Optimized layer caching** with dependency installation first

### Networking
- **Bridge network**: `craftista` for inter-service communication
- **Service discovery** via container names
- **Port mapping** for external access
- **Internal ports** for service-to-service communication

### Volumes & Persistence
- **PostgreSQL data**: Named volume `postgres_data`
- **Development mounts**: Optional bind mounts for live reload

### Health Checks
- **Catalogue service**: Socket connection test every 30s
- **Timeout**: 5 seconds
- **Retries**: 3 attempts

## Development Workflow

### Local Development
```bash
# Start all services
docker compose up -d --build

# View logs
docker compose logs -f

# Stop services
docker compose down

# Rebuild specific service
docker compose up -d --build <service-name>
```

### Service-Specific Development
```bash
# Catalogue (Python)
cd services/catalogue
pip install -r requirements.txt
python app.py

# Frontend (Node.js)
cd services/frontend
npm install
npm start

# Recommendation (Go)
cd services/recommendation
go run main.go

# Voting (Java)
cd services/voting
./mvnw spring-boot:run
```

## Production Considerations

### Security
- **Non-root users** in containers
- **Minimal base images** to reduce attack surface
- **Environment variables** for secrets (not committed)
- **No privileged containers**

### Performance
- **Resource limits** should be set in production
- **Health checks** for orchestration awareness
- **Logging** to stdout/stderr for container log aggregation
- **Graceful shutdown** handling

### Monitoring
- **Container metrics** via Docker stats
- **Application logs** via docker compose logs
- **Health endpoints** for service monitoring
- **Database monitoring** for PostgreSQL

## Deployment

### Docker Compose
```yaml
version: '3.8'
services:
  # Service definitions with build contexts
  # pointing to ./services/<service-name>
```

### Kubernetes (Future)
- **Deployments** for each service
- **Services** for internal networking
- **ConfigMaps** for configuration
- **Secrets** for sensitive data
- **PersistentVolumeClaims** for database storage

## Troubleshooting

### Common Issues
1. **Port conflicts**: Check if ports are already in use
2. **Build failures**: Ensure Docker has sufficient resources
3. **Network issues**: Verify container networking with `docker network ls`
4. **Database connection**: Check PostgreSQL logs and connection string

### Debug Commands
```bash
# Check container status
docker compose ps

# View service logs
docker compose logs <service-name>

# Execute into container
docker compose exec <service-name> sh

# Check network
docker network inspect craftista-demo_craftista
```

## File Structure

```
.
├── docker-compose.yaml          # Main orchestration file
├── services/                    # All microservices
│   ├── catalogue/
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   ├── requirements.txt
│   │   └── app.py
│   ├── frontend/
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   ├── package.json
│   │   └── app.js
│   ├── recommendation/
│   │   ├── Dockerfile
│   │   ├── .dockerignore
│   │   ├── go.mod
│   │   └── main.go
│   └── voting/
│       ├── Dockerfile
│       ├── .dockerignore
│       ├── pom.xml
│       └── src/
├── docs/
│   └── containerization.md      # This file
└── README.md
```

---

**Last Updated:** December 21, 2025
**Docker Version:** 24.0+
**Docker Compose Version:** 2.0+</content>
<parameter name="filePath">/home/kenzo/craftista-demo/docs/containerization.md