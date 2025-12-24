# Phase 0: Baseline - Craftista Demo Application

## Overview

The Craftista Demo is a microservices-based web application showcasing origami-themed content with product catalog, recommendations, and voting functionality. The application demonstrates modern containerized deployment using Docker Compose.

**Current Date:** December 21, 2025
**Status:** ✅ Fully operational with all services running

## Architecture Overview

### High-Level Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Catalogue     │    │ Recommendation  │
│   (Node.js)     │◄──►│   (Python)      │    │   (Go)          │
│   Port: 80      │    │   Port: 5000    │    │   Port: 8080    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                    ┌─────────────────┐    ┌─────────────────┐
                    │     Voting      │    │   Database      │
                    │   (Java)        │    │ (PostgreSQL)    │
                    │   Port: 8081    │    │   Port: 5432    │
                    └─────────────────┘    └─────────────────┘
```

### Service Components

#### 1. Frontend Service (`frontend/`)
- **Technology:** Node.js + Express.js + EJS
- **Purpose:** Main web interface and API gateway
- **External Port:** 80 (maps to internal 3000)
- **Key Features:**
  - Serves web UI with EJS templates
  - Acts as API gateway to backend services
  - Static file serving (CSS, JS, images)
  - Routes: `/` (home), `/api/origamis/*` (origami operations)

#### 2. Catalogue Service (`catalogue/`)
- **Technology:** Python + Flask + Gunicorn
- **Purpose:** Product catalog management
- **Port:** 5000
- **Key Features:**
  - REST API for origami product data
  - PostgreSQL database integration
  - Health check endpoint (socket connection test)
  - Data sources: JSON file + PostgreSQL database
- **API Endpoints:**
  - `GET /api/products` - List all products
  - `GET /api/products/<id>` - Get specific product

#### 3. Recommendation Service (`recommendation/`)
- **Technology:** Go + Gin framework
- **Purpose:** Provides origami recommendations
- **Port:** 8080
- **Key Features:**
  - "Origami of the day" recommendations
  - Recommendation status endpoint
- **API Endpoints:**
  - `GET /api/origami-of-the-day` - Daily recommendation
  - `GET /api/recommendation-status` - Service status

#### 4. Voting Service (`voting/`)
- **Technology:** Java + Spring Boot + H2
- **Purpose:** User voting on origami items
- **External Port:** 8081 (maps to internal 8080)
- **Key Features:**
  - Voting functionality for origami items
  - Scheduled data synchronization from catalogue service
  - H2 in-memory database for local storage
  - JPA/Hibernate ORM

#### 5. Database Service (`catalogue-db`)
- **Technology:** PostgreSQL 16.2 Alpine
- **Purpose:** Persistent storage for catalogue data
- **Port:** 5432 (internal only)
- **Configuration:**
  - Database: `catalogue`
  - User: `devops`
  - Password: `devops`

## Network Configuration

- **Docker Network:** `craftista` (bridge driver)
- **Service Discovery:** Internal DNS resolution using service names
- **External Access:** Mapped ports for web interface and APIs

## Data Flow

1. **User Access:** Frontend served on port 80
2. **API Orchestration:** Frontend calls backend services:
   - Catalogue API for product data
   - Recommendation API for suggestions
   - Voting API for user interactions
3. **Data Persistence:** Catalogue service reads/writes to PostgreSQL
4. **Data Sync:** Voting service periodically syncs origami data from Catalogue

## Deployment Configuration

### Docker Compose Services
- All services containerized with Docker
- Multi-stage builds for optimized images
- Health checks implemented for catalogue service
- Volume mounts for development (optional)

### Environment Configuration
- Configuration files: `config.json` in each service
- Database connection parameters
- API endpoint URLs
- Service dependencies defined

## Current Issues & Known Limitations

### Resolved Issues ✅
- **OpenJDK Image Issue:** Fixed invalid `openjdk:19-jdk-alpine3.16` → `eclipse-temurin:17-jdk-alpine`
- **Health Check:** Added socket-based health monitoring for catalogue service
- **Dependencies:** All Python packages properly specified in `requirements.txt`

### Known Limitations
- **Database Schema:** No explicit schema migration scripts
- **Error Handling:** Limited error handling in API responses
- **Logging:** Basic logging, no centralized log aggregation
- **Security:** No authentication/authorization implemented
- **Monitoring:** No metrics or monitoring dashboards
- **Testing:** Limited automated test coverage

## API Response Examples

### Catalogue API Response
```json
[
  {
    "id": "1",
    "name": "Origami Crane",
    "description": "Behold the delicate elegance of this Origami Crane...",
    "image_url": "/static/images/origami/001-origami.png"
  }
]
```

### System Info Endpoint
```json
{
  "hostname": "craftista-demo-catalogue-1",
  "ip_address": "172.18.0.3",
  "is_container": true,
  "is_kubernetes": false
}
```

## Development Environment

### Prerequisites
- Docker & Docker Compose
- Python 3.12+ (for local development)
- Node.js 18+ (for local development)
- Java 17+ (for local development)
- Go 1.19+ (for local development)

### Local Development Setup
```bash
# Install dependencies
cd catalogue && pip install -r requirements.txt
cd ../frontend && npm install

# Run services
docker compose up -d --build
```

### Testing Endpoints
```bash
# Test catalogue API
curl http://localhost:5000/api/products

# Test frontend
curl http://localhost:80

# View logs
docker compose logs -f
```

## Performance Baseline

- **Startup Time:** ~3-4 minutes for all services
- **Memory Usage:** ~500MB total for all containers
- **Response Time:** <100ms for API endpoints
- **Database:** 5 origami products seeded

## Next Phase Considerations

### Potential Improvements
1. **Database Migrations:** Add Flyway/Liquibase for schema management
2. **API Gateway:** Implement proper API gateway (Kong, Traefik)
3. **Authentication:** Add user authentication and authorization
4. **Monitoring:** Add Prometheus/Grafana for metrics
5. **Testing:** Increase automated test coverage
6. **CI/CD:** Add GitHub Actions for automated deployment
7. **Security:** Add HTTPS, secrets management
8. **Scalability:** Add Redis for caching, load balancing

### Phase 1 Goals
- Implement user authentication
- Add comprehensive API documentation
- Set up monitoring and logging
- Add automated testing pipeline
- Optimize database queries and caching

---

**Document Version:** 1.0
**Last Updated:** December 21, 2025
**Author:** AI Assistant
**Status:** Baseline established ✅</content>
<parameter name="filePath">/home/kenzo/craftista-demo/docs/phase-0-baseline.md
