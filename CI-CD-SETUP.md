# JOSDK Kubernetes Operator - CI/CD Setup Guide

## Overview

This CI/CD pipeline provides a comprehensive automation solution for building, testing, securing, and deploying your Kubernetes operator. It follows industry best practices and is based on proven patterns from production environments.

---

## 🏗️ Pipeline Architecture

### Job Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                   CODE PUSH / PR CREATED                     │
└────────────────────────┬────────────────────────────────────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
   BUILD & TEST   CODE QUALITY   SECURITY SCAN
        │                │                │
        └────────────────┼────────────────┘
                         │
                    VALIDATE K8S
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼ (master branch)      ▼ (develop branch)
   DOCKER BUILD          DOCKER BUILD
        │                      │
        ▼                      ▼
   PRODUCTION          STAGING
   DEPLOYMENT          DEPLOYMENT
```

### Jobs Overview

| Job | Trigger | Purpose | Branch |
|-----|---------|---------|--------|
| **build-and-test** | Always | Compile, unit test, package | All |
| **code-quality** | Always | Checkstyle, SpotBugs analysis | All |
| **security-scan** | Always | OWASP, Trivy scanning | All |
| **validate-k8s** | Always | Kubernetes manifest validation | All |
| **docker-build** | After all checks | Build and push Docker image | master, develop |
| **integration-test** | Manual/[integration] | End-to-end testing with KinD | On demand |
| **deploy-staging** | Docker built | Deploy to staging environment | develop |
| **deploy-production** | Docker built | Deploy to production | master |
| **notify** | Always | Pipeline status notification | All |

---

## 🚀 Getting Started

### Prerequisites

- GitHub repository with master and develop branches
- Java 25 (configured in workflow)
- Maven (mvnw included in repo)
- Docker (for local testing)

### Initial Setup

#### 1. **Enable GitHub Actions**
```bash
# Actions should be enabled by default
# Go to: Settings → Actions → General
# Ensure "Actions permissions" allows your workflows
```

#### 2. **Configure Branch Protection Rules** (Optional but Recommended)
```
Settings → Branches → Branch protection rules

For 'master' branch:
✅ Require status checks to pass before merging:
   - build-and-test
   - code-quality
   - security-scan
   - validate-k8s

✅ Require approvals before merging (recommended)
✅ Dismiss stale pull request approvals
✅ Require code reviews from CODEOWNERS
```

#### 3. **Configure Secrets** (Optional Enhancements)

Go to **Settings → Secrets and variables → Actions**

```bash
# Optional: NVD API Key for faster dependency scanning
NVD_API_KEY: <your-api-key>

# Optional: Deployment credentials (if using actual deployments)
STAGING_DEPLOY_KEY: <key>
PROD_DEPLOY_KEY: <key>
```

---

## 📊 Pipeline Details

### 1. Build & Test Job

**What it does:**
- ✅ Validates Maven configuration
- ✅ Runs unit tests
- ✅ Validates Google Java Style
- ✅ Builds and packages the application

**Triggers on:**
- Push to master/develop
- Pull requests to master/develop

**Artifacts generated:**
- Test reports: `target/surefire-reports/`
- JAR file: `target/josdkoperator-*.jar`

### 2. Code Quality Job

**What it does:**
- ✅ Runs Checkstyle (Google Java Format)
- ✅ Analyzes code style violations
- ✅ Generates quality reports

**Requires:** build-and-test

**Artifacts:**
- Checkstyle results
- Quality reports

### 3. Security Scan Job

**What it does:**
- ✅ OWASP Dependency Check (with optional NVD API)
- ✅ Scans for hardcoded secrets
- ✅ Trivy filesystem scanning
- ✅ Uploads SARIF reports to GitHub Security

**Requires:** build-and-test

**Continue on error:** Yes (non-blocking)

### 4. Validate K8s Job

**What it does:**
- ✅ Installs kubeconform
- ✅ Validates all YAML manifests
- ✅ Checks Kubernetes compliance

**Triggers on:** All pushes/PRs

### 5. Docker Build Job

**What it does:**
- ✅ Downloads build artifacts
- ✅ Sets up Docker Buildx (multi-platform)
- ✅ Builds multi-platform images (amd64, arm64)
- ✅ Pushes to GitHub Container Registry
- ✅ Tags images (branch, SHA, latest)

**Requires:** All quality jobs passed

**Only runs on:** master, develop branches

**Generated tags:**
```
ghcr.io/felipemello/k8-josdk-operator:master
ghcr.io/felipemello/k8-josdk-operator:develop
ghcr.io/felipemello/k8-josdk-operator:sha-abc123
ghcr.io/felipemello/k8-josdk-operator:latest (on master)
```

### 6. Integration Tests Job

**What it does:**
- ✅ Sets up KinD Kubernetes cluster
- ✅ Loads operator image
- ✅ Deploys operator to K8s
- ✅ Verifies deployment

**Triggers on:**
- Manual workflow dispatch
- Commit message contains `[integration]`

### 7. Deployment Jobs

**Staging** (develop branch):
```
docker-build:develop → deploy-staging
```

**Production** (master branch):
```
docker-build:latest → deploy-production
```

### 8. Notification Job

**What it does:**
- ✅ Provides build status summary
- ✅ Lists all checks passed/failed

---

## 🔄 Workflow Triggers

### Automatic Triggers

**Push to master:**
```bash
git push origin master
```
Pipeline runs → Docker builds → Production deployment

**Push to develop:**
```bash
git push origin develop
```
Pipeline runs → Docker builds → Staging deployment

**Pull Request:**
```bash
gh pr create
```
Pipeline runs all checks (no Docker push)

### Manual Triggers

**Run workflow manually:**
- Go to **Actions** tab
- Select **Kubernetes Operator CI/CD Pipeline**
- Click **Run workflow**

**Run integration tests:**
```bash
git commit -m "Update operator [integration]"
git push origin feature-branch
```

---

## 📝 Configuration Reference

### Environment Variables

```yaml
env:
  JAVA_VERSION: '25'           # Change if needed
  REGISTRY: ghcr.io            # GitHub Container Registry
  IMAGE_NAME: ${{ github.repository }}  # Auto-detected
```

### Branch Paths

```yaml
push:
  paths:
    - 'src/**'
    - 'pom.xml'
    - 'Dockerfile'
    - 'checkstyle.xml'
    - '.github/workflows/ci-cd.yml'
```

Only runs when these files change.

### Artifact Retention

```yaml
retention-days: 30  # Change to adjust storage time
```

---

## ✅ Quality Gates

### Build & Test
- ✅ Compilation succeeds
- ✅ Unit tests pass (100% required)
- ✅ Code style passes (Google format)

### Code Quality
- ✅ Checkstyle passes
- ✅ No obvious hardcoded secrets
- ✅ Code follows standards

### Security
- ✅ No critical vulnerabilities
- ✅ Dependency check passes
- ✅ Trivy scan passes

### Kubernetes
- ✅ All manifests valid
- ✅ CRDs properly defined
- ✅ RBAC correctly configured

---

## 🐛 Troubleshooting

### Build Fails with "Maven not found"
- Ensure `.mvn/` directory exists
- Ensure `mvnw` wrapper script is executable: `chmod +x mvnw`

### Checkstyle Failures
- Review Google Java Style Guide: https://google.github.io/styleguide/javaguide.html
- Fix: Run `./mvnw checkstyle:check` locally

### Docker Build Fails
- Ensure `Dockerfile` has all required files copied
- Check `checkstyle.xml` exists in project root
- Verify JAR file name matches `pom.xml` version

### K8s Validation Fails
- Install kubeconform locally: `kubeconform` checks YAML
- Run: `find k8s/ -name "*.yaml" -exec kubeconform -strict {} \;`

### Integration Tests Fail
- Ensure KinD is properly configured in `.github/kind-config.yaml`
- Check operator deployment status: `kubectl get deployment -n operators`
- View logs: `kubectl logs -n operators deployment/josdk-operator`

---

## 🔐 Security Best Practices

### Secrets Management
1. **Never commit secrets** to repository
2. Use GitHub Secrets for sensitive data
3. Rotate API keys regularly
4. Monitor security alerts in GitHub

### Docker Security
- Images run as non-root user
- Minimal Alpine-based runtime
- Health checks enabled
- Resource limits configured

### Code Security
- Google Java Style enforced
- OWASP dependency scanning enabled
- Hardcoded secrets detection
- Trivy filesystem scanning

---

## 📈 Monitoring & Insights

### GitHub Actions Dashboard
- **Actions** tab shows all workflow runs
- Click individual run for detailed logs
- View job timings and artifacts

### Security Tab
- **Security** → **Code scanning** shows Trivy results
- **Dependabot** shows vulnerability alerts
- **Secret scanning** prevents accidental commits

### Artifacts
- Download test reports for analysis
- Store quality reports for history
- Keep JAR files for debugging

---

## 🎯 Next Steps

1. **Commit workflow** to repository
2. **Push to master/develop** to trigger pipeline
3. **Monitor first run** in Actions tab
4. **Configure branch protection** (recommended)
5. **Set up deployments** to actual environments
6. **Customize notifications** (Slack, email, etc.)

---

## 📚 Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build & Push Action](https://github.com/docker/build-push-action)
- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
- [Trivy Security Scanner](https://github.com/aquasecurity/trivy)
- [Kubernetes kubeconform](https://github.com/yannh/kubeconform)
- [KinD: Kubernetes in Docker](https://kind.sigs.k8s.io/)

---

## 💡 Tips & Tricks

### Speed Up CI/CD
1. **Cache Docker layers:** Already enabled (`cache-from: type=gha`)
2. **Cache Maven:** Already enabled
3. **Parallel jobs:** Most jobs run in parallel

### Local Testing
```bash
# Test Maven build locally
./mvnw clean verify

# Test Docker build
docker build -t josdk-operator:test .

# Test K8s validation
kubeconform k8s/*.yaml
```

### Skip CI/CD
```bash
git commit -m "Update docs [skip ci]"
git push
# Pipeline won't run
```

---

## 🎉 Summary

Your JOSDK Kubernetes Operator now has:

✅ **Comprehensive CI/CD** - Automated build, test, quality checks  
✅ **Security scanning** - OWASP, Trivy, secret detection  
✅ **Code quality** - Google Java Style enforcement  
✅ **Kubernetes validation** - Manifest & configuration checks  
✅ **Docker automation** - Multi-platform builds, registry push  
✅ **Staging/Prod** - Environment-specific deployments  
✅ **Integration tests** - KinD-based end-to-end testing  
✅ **Notifications** - Status reporting and alerts  

**The pipeline is production-ready!** 🚀

