# 🚀 CI/CD Documentation

This folder contains everything you need to understand and use the JOSDK Kubernetes Operator CI/CD pipeline.

---

## 📚 Documentation Structure

### **START HERE**
**👉 [`CI-CD-GUIDE.md`](CI-CD-GUIDE.md)** - 2 minute quick start
- What you have (9 jobs, key features)
- Branch behavior (master, develop, PRs)
- Getting started in 3 steps
- Quick troubleshooting

### **FOR DETAILED SETUP**
**📖 [`CI-CD-SETUP.md`](CI-CD-SETUP.md)** - Complete reference (15 min)
- Full pipeline architecture
- Initial configuration
- Branch protection rules
- All job descriptions
- Security practices
- Monitoring & insights

### **FOR QUICK TASKS**
**⚡ [`CI-CD-QUICK-REFERENCE.md`](CI-CD-QUICK-REFERENCE.md)** - Quick lookup (5 min)
- Common tasks with commands
- Code style fixes
- Debugging failures
- Performance tips
- Common errors and solutions

---

## 🎯 Reading Guide

**Choose based on what you need:**

| Your Situation | Read This | Time |
|---|---|---|
| **New to this project** | CI-CD-GUIDE.md | 2 min |
| **Need to set up the pipeline** | CI-CD-SETUP.md | 15 min |
| **Have a quick question** | CI-CD-QUICK-REFERENCE.md | 5 min |
| **Code style failing** | CI-CD-QUICK-REFERENCE.md → Code Style section | 2 min |
| **Docker build failing** | CI-CD-SETUP.md → Troubleshooting | 5 min |

---

## 🔧 The Pipeline at a Glance

```
Your Code
   ↓
✅ Build & Test (compile, unit tests, package)
✅ Code Quality (Google Java Style validation)
✅ Security Scan (OWASP, Trivy, secrets detection)
✅ Validate K8s (Kubernetes manifest validation)
   ↓
[On master branch]     [On develop branch]
   ↓                        ↓
✅ Docker Build         ✅ Docker Build
✅ Deploy Production    ✅ Deploy Staging
```

---

## ⚡ Quick Start (2 minutes)

```bash
# 1. Push your code
git push origin master

# 2. Watch the pipeline
# → GitHub Repository → Actions tab

# 3. Done! ✅
```

---

## 📋 What's in Each File

### CI-CD-GUIDE.md
**Perfect for:** First-time readers, quick overview
```
- What you have (summary)
- Branch behavior
- Configuration (optional)
- Common tasks
- Performance metrics
- Troubleshooting basics
- Key files
```

### CI-CD-SETUP.md
**Perfect for:** Detailed reference, setup, configuration
```
- Complete pipeline architecture
- Getting started (detailed)
- Prerequisites
- Initial configuration
- Branch protection rules
- GitHub Secrets setup
- All job descriptions (8 jobs)
- Quality gates
- Security practices
- Troubleshooting
- Local testing
- Monitoring
```

### CI-CD-QUICK-REFERENCE.md
**Perfect for:** Quick lookup, specific problems
```
- Quick start (copy-paste)
- What happens on each branch
- Common tasks (with commands)
- Code style fixes
- Docker build testing
- K8s validation
- Integration tests
- Deployment workflow
- Performance tips
- Troubleshooting checklist
```

---

## ✅ Files Created

**Core Workflow:**
- `.github/workflows/ci-cd.yml` - Main CI/CD pipeline (9 jobs)

**Build Config:**
- `checkstyle.xml` - Google Java Style rules
- `pom.xml` - Maven build configuration
- `Dockerfile` - Multi-stage container build

**Documentation (this section):**
- `CI-CD-GUIDE.md` - Primary reference
- `CI-CD-SETUP.md` - Detailed setup guide
- `CI-CD-QUICK-REFERENCE.md` - Quick lookup

---

## 🎯 Common Questions

**Q: How do I run the pipeline?**
A: Just push to `master` or `develop` branch. It runs automatically.

**Q: How do I fix code style errors?**
A: See "Code Style Fixes" in `CI-CD-QUICK-REFERENCE.md`

**Q: What if Docker build fails?**
A: See "Troubleshooting" section in `CI-CD-SETUP.md`

**Q: Can I run integration tests?**
A: Yes, see "Run Integration Tests" in `CI-CD-QUICK-REFERENCE.md`

**Q: Where's the detailed configuration?**
A: See `CI-CD-SETUP.md` → Configuration section

---

## 📞 Need Help?

1. **Quick answer?** → `CI-CD-QUICK-REFERENCE.md`
2. **Detailed info?** → `CI-CD-SETUP.md`
3. **Getting started?** → `CI-CD-GUIDE.md`
4. **Check logs?** → GitHub Actions tab in your repo

---

## ✨ Key Facts

✅ **9 Automated Jobs**
- Build, test, quality, security, validation, deployment, notification

✅ **Production Ready**
- Multi-platform Docker (amd64, arm64)
- Automatic deployments
- Security scanning enabled

✅ **Zero Manual Work**
- Push code, pipeline runs automatically
- All validation automatic
- Deployment automatic

✅ **Fast**
- First run: 10-15 minutes
- Cached runs: 5-8 minutes
- Parallel jobs for speed

✅ **Free**
- GitHub Actions free tier
- No costs for this pipeline

---

**Last Updated:** April 6, 2026  
**Status:** ✅ Production-ready

---

**Start with [`CI-CD-GUIDE.md`](CI-CD-GUIDE.md) → 2 minute read!** 🚀

