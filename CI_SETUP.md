# GitHub Actions CI Setup Guide

## Quick Start

Your CI pipeline is ready! Follow these steps to activate it:

### 1. Get Docker Hub Credentials

- Go to [Docker Hub Account Settings](https://hub.docker.com/settings/account)
- Click **Security** → **New Access Token**
- Give it a name: `github-actions`
- Copy the token (you'll need it in the next step)

### 2. Add GitHub Secrets

Go to your GitHub repo → **Settings** → **Secrets and variables** → **Actions**

Add these two secrets:
- **Name:** `DOCKER_HUB_USERNAME`
  - **Value:** Your Docker Hub username
  
- **Name:** `DOCKER_HUB_PASSWORD`
  - **Value:** Your access token from step 1

### 3. Update docker-compose.yaml (Optional)

If you want to use the pushed images locally, update the image names:

```yaml
# Change from:
image: my/craftista-frontend:dev

# To:
image: <your-docker-hub-username>/craftista-frontend:latest
```

### 4. Push & Test

```bash
git add .github/workflows/ci.yml
git commit -m "feat: add GitHub Actions CI pipeline"
git push origin main
```

Go to **Actions** tab on GitHub to watch it run!

---

## 📊 What the Pipeline Does

### On Every Push & Pull Request:

1. **Lint & Test** (parallel for all 4 services)
   - Frontend: npm test
   - Catalogue: pytest
   - Voting: mvn test
   - Recommendation: go test

2. **Build Docker Images** (only if tests pass)
   - Builds all 4 services in parallel
   - Pushes to Docker Hub (only on main branch)
   - Uses smart caching for speed

3. **Verify docker-compose** (optional)
   - Validates configuration syntax

### Image Tagging Strategy

Images are tagged with:
- `latest` - on main branch
- `develop` - on develop branch
- `<branch>-<short-sha>` - on feature branches
- Supports semantic versioning tags

---

## 🔐 Security Features

- ✅ Secrets never logged
- ✅ Cache optimization (no credential leaks)
- ✅ Tests run before builds
- ✅ Images only pushed from main branch
- ✅ Docker login only when needed

---

## 🚀 Next Steps (Optional)

### Add Branch Protection Rules

Go to **Settings** → **Branches** → **Branch Protection Rules**

Create a rule for `main`:
- ✅ Require status checks to pass (select all CI jobs)
- ✅ Require PR reviews
- ✅ Dismiss stale PR approvals

### Add Security Scanning

Uncomment the security job in ci.yml to scan images for vulnerabilities:

```yaml
scan-images:
  needs: build-images
  runs-on: ubuntu-latest
  steps:
    - name: Run Trivy scan
      uses: aquasecurity/trivy-action@master
```

---

## 📝 Troubleshooting

### Pipeline fails at Docker login
- Check secrets are correctly named
- Verify Docker Hub token is valid
- Ensure token has read/write permissions

### Tests fail locally but pass in CI (or vice versa)
- Check Node/Python/Java/Go versions in workflow
- Ensure test dependencies are installed
- Check working directory paths

### Images not pushing to Docker Hub
- Pipeline only pushes on `main` branch pushes
- Feature branches build but don't push (safe!)
- Check GitHub Actions logs for errors

---

## 📖 Resources

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Docker Build Push Action](https://github.com/docker/build-push-action)
- [Docker Metadata Action](https://github.com/docker/metadata-action)

---

**Your CI/CD is now live!** 🚀
