# JOSDK CI/CD - Quick Reference Guide

## 📊 Pipeline Overview at a Glance

### What Happens on Each Branch

#### 🔄 Pull Request to master/develop
```
✅ Build & Test
✅ Code Quality
✅ Security Scan
✅ Validate K8s Manifests
❌ Docker Build (skipped)
❌ Deployment (skipped)
```

#### 🚀 Push to master (Production)
```
✅ Build & Test
✅ Code Quality
✅ Security Scan
✅ Validate K8s Manifests
✅ Docker Build & Push → ghcr.io/.../latest
✅ Deploy to Production
```

#### 🏗️ Push to develop (Staging)
```
✅ Build & Test
✅ Code Quality
✅ Security Scan
✅ Validate K8s Manifests
✅ Docker Build & Push → ghcr.io/.../develop
✅ Deploy to Staging
```

---

## 🎯 Common Tasks

### Run All Checks Locally

```bash
# Clean and run all Maven checks
./mvnw clean verify

# With test output
./mvnw clean verify -X

# Skip checkstyle (temporary)
./mvnw clean verify -Dcheckstyle.skip
```

### Test Docker Build

```bash
# Build Docker image
docker build -t josdk-operator:local .

# Run the container
docker run -p 8080:8080 josdk-operator:local
```

### Validate Kubernetes Manifests

```bash
# Install kubeconform
curl -LO https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz
tar -xzf kubeconform-linux-amd64.tar.gz
sudo mv kubeconform /usr/local/bin/

# Validate all YAML files
find k8s/ -name "*.yaml" -exec kubeconform -strict {} \;
```

### Test Integration Locally

```bash
# Install KinD
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/

# Create cluster
kind create cluster --config .github/kind-config.yaml

# Deploy operator
kubectl create namespace operators
kubectl apply -f k8s/

# Check status
kubectl get deployment -n operators
kubectl logs -n operators deployment/josdk-operator
```

---

## 📋 Code Style Fixes

### Fix Checkstyle Issues Automatically

```bash
# Google Java Format tool
mvn com.spotify.fmt:fmt-maven-plugin:format
```

### Common Checkstyle Issues

| Issue | Fix |
|-------|-----|
| Line too long (>100 chars) | Break into multiple lines |
| Missing Javadoc | Add `/** comment */` |
| Wildcard imports | Replace `import foo.*` with specific imports |
| Wrong indentation | Use 2-space indentation (not tabs) |
| Unused imports | Remove unused imports |

---

## 🔍 Debugging Pipeline Failures

### Step 1: Check GitHub Actions Logs
1. Go to **Actions** tab
2. Click on the failed workflow run
3. Click on the failed job
4. Review the step output

### Step 2: Common Errors

**Error:** `Could not find resource 'checkstyle.xml'`
```
✅ Fix: Ensure checkstyle.xml exists in project root
git add checkstyle.xml
git commit -m "Add checkstyle configuration"
git push
```

**Error:** `Failed to build: exit code 1`
```
✅ Fix: Run locally to see actual error
./mvnw clean verify
# Fix the error, then push again
```

**Error:** `invalid tag "ghcr.io/.../:-abc123"`
```
✅ Fix: This is already fixed in the new workflow
Just ensure you're using the updated ci-cd.yml
```

---

## 🚀 Deployment Workflow

### Manual Trigger Integration Tests

```bash
# Method 1: Include [integration] in commit message
git commit -m "Update operator [integration]"
git push origin feature-branch

# Method 2: Manual workflow dispatch
# Go to Actions → Kubernetes Operator CI/CD → Run workflow
```

### Deploy to Staging

```bash
# Push to develop
git checkout develop
git merge feature-branch
git push origin develop

# Wait for pipeline to complete
# Check Actions tab for status
```

### Deploy to Production

```bash
# Create pull request
git push origin feature-branch
# Open PR to master
# Wait for all checks to pass
# Merge PR

# Or push directly to master
git checkout master
git merge feature-branch
git push origin master

# Pipeline auto-deploys to production
```

---

## 📊 Docker Image Tags

### Generated Tags Example

For commit `abc123def456` on branch `master`:

```
ghcr.io/felipemello/k8-josdk-operator:master
ghcr.io/felipemello/k8-josdk-operator:abc123def456
ghcr.io/felipemello/k8-josdk-operator:latest
```

For commit `xyz789` on branch `develop`:

```
ghcr.io/felipemello/k8-josdk-operator:develop
ghcr.io/felipemello/k8-jsdk-operator:xyz789
```

For PR #42:

```
ghcr.io/felipemello/k8-josdk-operator:pr-42
ghcr.io/felipemello/k8-josdk-operator:xyz789
```

---

## 🔐 Security Checklist

- [ ] No hardcoded passwords in code
- [ ] No API keys in commits
- [ ] All dependencies up-to-date
- [ ] Security scan passes (Trivy)
- [ ] OWASP dependency check passes
- [ ] Code follows style guide
- [ ] Kubernetes manifests validated

---

## ⚡ Performance Tips

### Speed Up Builds

```bash
# Use parallel builds (faster compilation)
./mvnw clean verify -T 1C

# Skip certain checks if needed (temporary)
./mvnw clean verify -Dcheckstyle.skip -Dspotbugs.skip

# Use offline mode if dependencies cached
./mvnw clean verify -o
```

### Docker Build Cache

Cache is automatically managed:
- ✅ Maven dependencies cached
- ✅ Docker layers cached (via GitHub Actions)
- ✅ Typically 50-70% faster on rebuilds

---

## 📈 Monitoring

### GitHub Actions Insights

```
Actions → Kubernetes Operator CI/CD Pipeline

View:
- Execution time
- Success/failure rates
- Job durations
- Artifact usage
```

### Artifact Management

Test reports and JAR files are kept for 30 days:
```yaml
retention-days: 30
```

Change in workflow if needed:
```yaml
retention-days: 60  # Keep longer
retention-days: 7   # Keep shorter
```

---

## 🆘 Support

### Check Logs
- **Build logs:** Actions tab → failed job → step output
- **Docker logs:** Local testing with `docker build -t test .`
- **K8s logs:** `kubectl logs -n operators deployment/josdk-operator`

### Common Solutions

1. **Clean and rebuild:** `./mvnw clean verify -U`
2. **Update dependencies:** Check `pom.xml` versions
3. **Reset cache:** GitHub Actions cache auto-resets
4. **Check branch:** Ensure pushing to `master` or `develop`

---

## 📝 Workflow Summary

| Component | Purpose | Status |
|-----------|---------|--------|
| Build & Test | Compile & unit tests | ✅ Required |
| Code Quality | Checkstyle validation | ✅ Required |
| Security Scan | OWASP, Trivy, secrets | ✅ Required |
| K8s Validation | Manifest validation | ✅ Required |
| Docker Build | Container build & push | ✅ On master/develop |
| Integration Tests | KinD end-to-end | ✅ On demand |
| Staging Deploy | Develop branch deploy | ✅ On develop push |
| Prod Deploy | Master branch deploy | ✅ On master push |

---

## 🎉 You're All Set!

Your JOSDK Kubernetes Operator has a professional-grade CI/CD pipeline!

```
✅ Automatic testing on every commit
✅ Security scanning enabled
✅ Code quality enforced
✅ Docker images built & published
✅ Automatic deployments
✅ Integration testing available
✅ Production-ready
```

**Next Step:** Push your first commit to test the pipeline!

```bash
git add .
git commit -m "Add professional CI/CD pipeline"
git push origin master
```

Watch it all work in the Actions tab! 🚀

