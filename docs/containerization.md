# Containerization Documentation

## Overview

This document describes the containerization setup for the Craftista microservices application.

## Architecture

Craftista is a microservices-based application with the following services:

### Services

1. **Catalogue Service** (Python/Flask)
   - **Port:** 5000
   - **Description:** Manages product catalog with origami items
   - **Technology:** Python 3.11, Flask, Gunicorn
   - **Database:** PostgreSQL (configurable) or JSON file

2. **Frontend Service** (Node.js/Express)
   - **Port:** 3000
   - **Description:** Main web interface serving the application UI
   - **Technology:** Node.js 18, Express, EJS templates
   - **Dependencies:** Depends on all other services

3. **Recommendation Service** (Go/Gin)
   - **Port:** 8081 (mapped from internal 8080)
   - **Description:** Provides product recommendations
   - **Technology:** Go 1.20, Gin framework
   - **Build:** Multi-stage build for optimized image size

4. **Voting Service** (Java/Spring Boot)
   - **Port:** 8080
   - **Description:** Handles voting functionality for origami items
   - **Technology:** Java 17, Spring Boot 2.5.5, H2 Database
   - **Database:** H2 in-memory database
   - **Build:** Multi-stage Maven build

## Directory Structure

```
craftista/
├── docker-compose.yml          # Orchestration configuration
├── docs/
│   └── containerization.md     # This file
└── services/
    ├── catalogue/
    │   ├── Dockerfile          # Python/Flask container
    │   ├── .dockerignore       # Build exclusions
    │   ├── app.py              # Main application
    │   ├── requirements.txt    # Python dependencies
    │   ├── config.json         # Configuration
    │   └── products.json       # Product data
    ├── frontend/
    │   ├── Dockerfile          # Node.js container
    │   ├── .dockerignore       # Build exclusions
    │   ├── app.js              # Express application
    │   ├── package.json        # Node dependencies
    │   └── config.json         # Configuration
    ├── recommendation/
    │   ├── Dockerfile          # Go container (multi-stage)
    │   ├── .dockerignore       # Build exclusions
    │   ├── main.go             # Go application
    │   ├── go.mod              # Go dependencies
    │   └── config.json         # Configuration
    └── voting/
        ├── Dockerfile          # Java/Spring Boot container (multi-stage)
        ├── .dockerignore       # Build exclusions
        ├── pom.xml             # Maven dependencies
        └── src/                # Java source code
```

## Docker Images

### Base Images Used

- **Catalogue:** `python:3.11-slim`
- **Frontend:** `node:18-alpine`
- **Recommendation:** `golang:1.20-alpine` (builder), `alpine:latest` (runtime)
- **Voting:** `maven:3.8-openjdk-17-slim` (builder), `eclipse-temurin:17-jre-alpine` (runtime)

### Image Optimization

- Multi-stage builds for Go and Java services to reduce final image size
- Alpine-based images where possible for smaller footprint
- `.dockerignore` files to exclude unnecessary files from build context
- Dependency layers cached separately for faster rebuilds

## Networking

All services are connected via a custom bridge network: `craftista-network`

### Service Communication

Services communicate using container names as hostnames:

- Frontend → Catalogue: `http://catalogue:5000`
- Frontend → Recommendation: `http://recco:8080`
- Frontend → Voting: `http://voting:8080`
- Voting → Catalogue: `http://catalogue:5000`

## Configuration

### Environment Variables

Each service can be configured via environment variables:

- **Catalogue:** `FLASK_ENV=production`
- **Frontend:** `NODE_ENV=production`
- **Voting:** `SPRING_PROFILES_ACTIVE=default`

### Service Configuration Files

Each service has its own `config.json` for application-specific settings:

- **Catalogue:** Database connection, data source selection
- **Frontend:** API endpoints for other services
- **Recommendation:** Version information
- **Voting:** Configured via `application.properties`

## Building and Running

### Build All Services

```bash
docker compose build
```

### Build Specific Service

```bash
docker compose build catalogue
```

### Start All Services

```bash
docker compose up -d
```

### Start Specific Service

```bash
docker compose up -d catalogue
```

### Stop All Services

```bash
docker compose down
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f catalogue
```

### Check Service Status

```bash
docker compose ps
```

## Port Mappings

| Service        | Internal Port | External Port | URL                        |
|----------------|---------------|---------------|----------------------------|
| Catalogue      | 5000          | 5000          | http://localhost:5000      |
| Frontend       | 3000          | 3000          | http://localhost:3000      |
| Recommendation | 8080          | 8081          | http://localhost:8081      |
| Voting         | 8080          | 8080          | http://localhost:8080      |

## Troubleshooting

### Port Conflicts

If you encounter "port already in use" errors:

```bash
# Check what's using the port
sudo lsof -i :PORT_NUMBER

# Or list all Docker containers
docker ps -a

# Stop conflicting containers
docker stop CONTAINER_NAME
```

### Container Logs

```bash
# View logs for debugging
docker logs CONTAINER_NAME

# Follow logs in real-time
docker logs -f CONTAINER_NAME

# View last 50 lines
docker logs --tail 50 CONTAINER_NAME
```

### Rebuild from Scratch

```bash
# Remove all containers and images
docker compose down --rmi all

# Rebuild everything
docker compose build --no-cache

# Start services
docker compose up -d
```

### Access Container Shell

```bash
# Python/Catalogue
docker exec -it catalogue /bin/bash

# Node.js/Frontend
docker exec -it frontend /bin/sh

# Go/Recommendation
docker exec -it recco /bin/sh

# Java/Voting
docker exec -it voting /bin/sh
```

## Development Workflow

1. Make changes to service code
2. Rebuild the specific service: `docker compose build SERVICE_NAME`
3. Restart the service: `docker compose up -d SERVICE_NAME`
4. Check logs: `docker compose logs -f SERVICE_NAME`
5. Test the changes via the appropriate endpoint

## Production Considerations

### Security

- Use specific image tags instead of `latest`
- Implement proper secrets management (not in config files)
- Run containers as non-root users
- Scan images for vulnerabilities regularly

### Monitoring

- Add health check endpoints to each service
- Implement centralized logging
- Set up container monitoring and alerting
- Use resource limits in docker-compose.yml

### Scaling

- Use Docker Swarm or Kubernetes for orchestration
- Implement load balancing for frontend service
- Add database persistence with volumes
- Configure horizontal scaling for stateless services

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Best Practices for Writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
