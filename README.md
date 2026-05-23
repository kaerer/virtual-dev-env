# 🚀 Virtual Development Environments

This repository contains standardized, modular virtual development environment configurations using **Multipass**, **Nix**, and **Docker/K3s**. It is designed to provide a consistent coding environment across different tech stacks.

Each subfolder is a **standalone template** — copy it into your project and customize.

---

## 📂 Project Structure

### 1. Simple Environment (`/simple`)
Managed through manual config editing. Best for fixed, long-term environments.
- **Tools:** PHP, Node.js, Python, Git (Managed via `.virtual-dev-env/shell.nix`).

### 2. Complex Environment (`/complex`)
Advanced orchestrator using CLI overrides. Change anything on-the-fly.
- **Tools:** Dynamic PHP/Node versions, optional Databases (Redis, Postgres, MariaDB, SQLite).

### 3. Docker Environment (`/docker`)
Container-based workflow with Docker Compose and local Kubernetes (K3s).
- **Tools:** Modular runtimes, DB Profiles, and K3s cluster management via `k3d`.

### 4. Docker Advanced Environment (`/docker-advanced`) 🆕
Modern, Docker-based polyglot development environment. Go + PHP + Node + Python in one container, plus optional databases (PostgreSQL, Redis) and email testing (Mailpit).
- **Tools:** Go, PHP 8.3, Node 20, Composer, Air (hot-reload), Xdebug, PostgreSQL 16, Redis 7, Mailpit
- **Architecture:** Container-First with Docker Compose profiles

---

## 🚀 Quick Start

### Prerequisites
- **Multipass / Nix:** For VM and lightweight shells.
- **Docker / k3d:** For containerized and K8s environments.

### Usage

#### Simple Setup:
```bash
cd simple
make n-shell          # Open Nix shell
make setup-vm         # Create Multipass VM
```

#### Complex Setup (Dynamic):
```bash
cd complex
make n-shell PHP_VER=php83 DATABASES="postgres redis"
make setup-vm VM_MEM=4G PHP_VER=php83
```

#### Docker & K3s Setup:
```bash
cd docker
make build PHP_VER=8.3 NODE_VER=20   # Build custom container
make up DATABASES="redis mariadb"    # Start with specific DBs
make k3s-up                          # Spin up local K3s cluster
```

#### Docker Advanced Setup (Recommended) 🆕:
```bash
cd docker-advanced
make up                              # Start workspace container
make up DATABASES="postgres redis"   # Start with databases
make shell                           # Enter the environment
```

---

## 🛠 Features

| Feature | Simple | Complex | Docker/K3s | Docker Advanced 🆕 |
| :--- | :---: | :---: | :---: | :---: |
| **Runtime** | Nix Shell / VM | Nix Shell / VM | Docker Compose | Docker Compose |
| **Variable Overrides** | ❌ Manual edit | ✅ CLI + .env | ✅ CLI + .env | ✅ CLI + .env |
| **Standalone** | ✅ Full folder | ✅ Full folder | ✅ Full folder | ✅ Full folder |
| **.env support** | ✅ | ✅ | ✅ | ✅ |
| **make setup** | ✅ | ✅ | ✅ | ✅ |
| **make test/lint** | ❌ | ❌ | ❌ | ✅ |
| **Database Profiles** | ❌ | ✅ | ✅ | ✅ |
| **Kubernetes (K3s)** | ❌ | ❌ | ✅ | ❌ |
| **Go included** | ❌ | ✅ (partial) | ❌ | ✅ |
| **Architecture** | Config-First | Orchestrator-First | Container-First | Docker-Advanced-First |

---

## 📝 TODO / Roadmap

- [x] **Docker Integration:** Container-based modular setup.
- [x] **Kubernetes/K3s:** Local K8s development via k3d.
- [ ] **Custom Cloud-Init Templates:** More specialized OS images (Debian, Arch).
- [ ] **Automated Testing:** CI/CD integration for environment validation.
- [ ] **GUI Dashboard:** Visual management interface for all environments.

---

> [!TIP]
> Use `make help` inside each folder to see the most up-to-date commands and your current configuration defaults.
