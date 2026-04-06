# 📖 JOSDK Operator - Documentation Index

## 🎯 Quick Links

### 🚀 **QUICKSTART.md** → [`QUICKSTART.md`](QUICKSTART.md)
- **Best for**: Getting started quickly
- **Contains**: TL;DR setup, testing, troubleshooting
- **Read time**: 10 minutes

### 📋 **Docker + KinD Guide** → [`DOCKER_KIND_GUIDE.md`](DOCKER_KIND_GUIDE.md)
- **Best for**: Understanding the full setup
- **Contains**: Complete guide, troubleshooting, architecture
- **Read time**: 15 minutes

### 🔧 **Spring Boot Configuration** → [`SPRING_BOOT_GUIDE.md`](SPRING_BOOT_GUIDE.md)
- **Best for**: Customization and configuration
- **Contains**: Spring Boot integration, best practices
- **Read time**: 10 minutes

### 📝 **Changes Log** → [`CHANGES.md`](CHANGES.md)
- **Best for**: Understanding what was modified
- **Contains**: Complete change history, before/after
- **Read time**: 10 minutes

---

## 🚀 **CI/CD Pipeline**

### GitHub Actions Workflow
This project includes a comprehensive CI/CD pipeline powered by GitHub Actions:

#### **Pipeline Features:**
- ✅ **Automated Testing**: Unit tests, integration tests, code quality checks
- ✅ **Docker Build**: Automated container image building and publishing
- ✅ **Security Scanning**: Vulnerability scanning with Trivy
- ✅ **Kubernetes Validation**: Manifest validation with kubeconform
- ✅ **Code Coverage**: JaCoCo coverage reports
- ✅ **Multi-Stage Pipeline**: Parallel jobs for efficiency

#### **Workflow Triggers:**
- **Push to main/develop**: Full CI/CD pipeline
- **Pull Requests**: Validation and testing
- **Manual Trigger**: Integration tests on demand
- **Tag Creation**: Automated releases

#### **Pipeline Jobs:**
1. **build-and-test**: Java compilation, unit tests, packaging
2. **build-docker**: Container image build and push to GHCR
3. **validate-k8s**: Kubernetes manifest validation
4. **security-scan**: Vulnerability scanning and SARIF reports
5. **code-quality**: Checkstyle, SpotBugs, code coverage
6. **integration-test**: KinD-based integration testing (manual/on-demand)
7. **release**: Automated GitHub releases on tags

#### **Viewing CI/CD Results:**
```bash
# Check workflow status
gh workflow list
gh workflow view ci-cd.yml

# View latest run
gh run list --workflow=ci-cd.yml
gh run view <run-id>
```

---

## 📚 Documentation by Task

### "I want to run this right now"
→ [QUICKSTART.md](QUICKSTART.md)

### "I want to understand how it works"
→ [DOCKER_KIND_GUIDE.md](DOCKER_KIND_GUIDE.md)

### "I want to customize the operator"
→ [SPRING_BOOT_GUIDE.md](SPRING_BOOT_GUIDE.md)

### "I want to see what changed"
→ [CHANGES.md](CHANGES.md)

---

## 🎯 Choose Your Path

### Path 1: "Just Run It!" ⚡ (Recommended)
```
1. Read: QUICKSTART.md (10 min)
2. Run: ./scripts/setup-kind.sh (2 min)
3. Test: ./scripts/test.sh (1 min)
```
**Total time: 13 minutes**

### Path 2: "Understand Everything"
```
1. Read: QUICKSTART.md (10 min)
2. Read: DOCKER_KIND_GUIDE.md (15 min)
3. Read: SPRING_BOOT_GUIDE.md (10 min)
```
**Total time: 35 minutes**

### Path 3: "Customize Before Deployment"
```
1. Read: QUICKSTART.md (10 min)
2. Edit: WebPageReconciler.java
3. Read: SPRING_BOOT_GUIDE.md (10 min)
4. Run: ./scripts/setup-kind.sh (2 min)
```
**Total time: 22 minutes**

---

## 📁 Project Structure

```
/workspace/josdk/
│
├── 📖 DOCUMENTATION
│   ├── README.md                      ← This index
│   ├── QUICKSTART.md                  ← Quick start guide
│   ├── DOCKER_KIND_GUIDE.md           ← Complete deployment
│   ├── SPRING_BOOT_GUIDE.md           ← Configuration
│   └── CHANGES.md                     ← Change history
│
├── 🚀 CI/CD
│   └── .github/
│       ├── workflows/ci-cd.yml        ← GitHub Actions pipeline
│       └── kind-config.yaml           ← KinD configuration
│
├── 🐳 DOCKER
│   └── Dockerfile                     ← Container definition
│
├── ⚙️ KUBERNETES
│   └── k8s/
│       ├── crd-webpage.yaml           ← Custom Resource Definition
│       ├── rbac.yaml                  ← Permissions
│       ├── operator-deployment.yaml   ← Operator deployment
│       └── example-webpages.yaml      ← Test resources
│
├── 🔧 SCRIPTS
│   └── scripts/
│       ├── setup-kind.sh              ← Automated setup
│       ├── test.sh                    ← Automated testing
│       └── cleanup.sh                 ← Automated cleanup
│
├── 📦 BUILD
│   ├── pom.xml                        ← Maven configuration
│   ├── mvnw                           ← Maven wrapper
│   ├── checkstyle.xml                 ← Code style rules
│   └── target/
│       └── josdkoperator-*.jar        ✅ Built JAR
│
└── 📝 SOURCE CODE
    └── src/
        ├── main/java/com/k8/josdkoperator/
        │   ├── JosdkOperatorApplication.java  ← Main entry point
        │   ├── WebPageReconciler.java         ← Reconciliation logic
        │   └── customresource/                ← CRD definitions
        │       ├── WebPage.java
        │       ├── WebPageSpec.java
        │       └── WebPageStatus.java
        └── test/java/com/k8/josdkoperator/
            └── JosdkOperatorApplicationTests.java  ← Unit tests
```

---

## ✅ What's Ready

- ✅ **Java Code**: JOSDK operator fully implemented
- ✅ **Build**: Maven build succeeds (37 MB JAR)
- ✅ **Docker**: Dockerfile ready to build image
- ✅ **Kubernetes**: All manifests configured
- ✅ **Automation**: Scripts ready to run
- ✅ **CI/CD**: GitHub Actions pipeline configured
- ✅ **Testing**: Unit tests included
- ✅ **Documentation**: Streamlined guides

---

## 🚀 3-Minute Quick Start

```bash
cd /workspace/josdk
./scripts/setup-kind.sh
```

Done! Your operator is running in KinD.

---

## 📚 Documentation Map

| Document | Purpose | Level | Read Time |
|----------|---------|-------|-----------|
| [README.md](README.md) | Documentation index | All | 5 min |
| [QUICKSTART.md](QUICKSTART.md) | Quick start guide | Beginner | 10 min |
| [DOCKER_KIND_GUIDE.md](DOCKER_KIND_GUIDE.md) | Complete deployment | Intermediate | 15 min |
| [SPRING_BOOT_GUIDE.md](SPRING_BOOT_GUIDE.md) | Configuration | Advanced | 10 min |
| [CHANGES.md](CHANGES.md) | Change history | Reference | 10 min |

---

## 🎓 Learning Outcomes

After following this guide, you will:
- ✅ Understand Java Operators on Kubernetes
- ✅ Know how to containerize Java applications
- ✅ Be able to deploy operators with KinD
- ✅ Understand JOSDK fundamentals
- ✅ Know how to test operators
- ✅ Be able to extend the operator
- ✅ **NEW**: Understand CI/CD for Kubernetes operators
- ✅ **NEW**: Know how to automate operator testing
- ✅ **NEW**: Learn container security scanning
- ✅ **NEW**: Understand code quality automation

---

## 💡 Key Concepts

### Custom Resource Definition (CRD)
Defines a new Kubernetes resource type. See: `k8s/crd-webpage.yaml`

### Reconciler
The core logic that watches CRs and creates/updates resources. See: `WebPageReconciler.java`

### Operator
Your Java application that implements the reconciler. See: `JosdkOperatorApplication.java`

### KinD
Kubernetes in Docker - runs a full K8s cluster in Docker. Used for development.

### RBAC
Role-Based Access Control - grants permissions to the operator.

### **NEW: CI/CD Pipeline**
Automated testing, building, and deployment using GitHub Actions.

---

## 🔗 Quick Commands

### One-Liner Deployment
```bash
cd /workspace/josdk && ./scripts/setup-kind.sh
```

### Monitor Operator
```bash
kubectl logs -f -n operators deployment/josdk-operator
```

### Run Tests
```bash
./scripts/test.sh
```

### Cleanup
```bash
./scripts/cleanup.sh
```

### **NEW: Check CI/CD**
```bash
# View workflow status
gh workflow view ci-cd.yml

# Check latest run
gh run list --workflow=ci-cd.yml
```

---

## 📊 Technology Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| Java | 25.0.2 | Runtime |
| Maven | 3.9.14 | Build tool |
| Spring Boot | 4.0.5 | Application framework |
| JOSDK | 5.3.2 | Operator framework |
| Kubernetes | Latest | Target platform |
| KinD | Latest | Local K8s cluster |
| Docker | Latest | Container runtime |
| **NEW: GitHub Actions** | Latest | CI/CD platform |
| **NEW: Trivy** | Latest | Security scanning |
| **NEW: JaCoCo** | 0.8.11 | Code coverage |

---

## ✨ Next Steps

1. **Read**: Pick a guide from above
2. **Run**: Execute the setup scripts
3. **Test**: Verify with test scripts
4. **Extend**: Modify the operator code
5. **Deploy**: Push to production
6. **Monitor**: Check CI/CD pipeline results

---

## 📞 Need Help?

### If you're stuck...
1. Check the troubleshooting section in [QUICKSTART.md](QUICKSTART.md)
2. Check the logs: `kubectl logs -f -n operators deployment/josdk-operator`
3. Check pod status: `kubectl describe pod -n operators -l app=josdk-operator`
4. Verify RBAC: `kubectl get clusterrolebinding josdk-operator`

### **NEW: CI/CD Issues**
1. Check GitHub Actions tab in your repository
2. View workflow logs for detailed error messages
3. Check security scan results in Security tab
4. Verify container image in Packages

### If you want to customize...
1. Edit `src/main/java/com/k8/josdkoperator/WebPageReconciler.java`
2. Read [SPRING_BOOT_GUIDE.md](SPRING_BOOT_GUIDE.md) for configuration options
3. Rebuild: `./mvnw clean package && docker build -t josdk-operator:1.0 .`
4. Redeploy: `kind load docker-image josdk-operator:1.0 --name operator-dev`

### If you want to learn more...
- [JOSDK Official Docs](https://javaoperatorsdk.io/)
- [Kubernetes Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/)
- [KinD Documentation](https://kind.sigs.k8s.io/)
- **[NEW] GitHub Actions](https://docs.github.com/en/actions)
- **[NEW] Container Security](https://aquasecurity.github.io/trivy/)

---

## 🎉 Summary

You have a **fully functional Java Kubernetes Operator** with:
- ✅ Complete source code
- ✅ Automated deployment scripts
- ✅ Streamlined documentation
- ✅ Example resources
- ✅ Testing utilities
- ✅ **NEW: Complete CI/CD pipeline**
- ✅ **NEW: Security scanning**
- ✅ **NEW: Code quality automation**
- ✅ **NEW: Container registry integration**

**Ready to deploy?**

```bash
./scripts/setup-kind.sh
```

---

**Last Updated**: April 6, 2026  
**Status**: ✅ Complete and Ready  
**Next**: Read [QUICKSTART.md](QUICKSTART.md) or run `./scripts/setup-kind.sh`
