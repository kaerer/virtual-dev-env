# 🚀 Virtual Development Environments / Sanal Geliştirme Ortamları

🇺🇸 **EN:** This repository contains standardized, internationalized, and modular virtual development environment configurations using **Multipass**, **Nix**, and **Docker/K3s**. It is designed to provide a consistent coding environment across different tech stacks.

🇹🇷 **TR:** Bu depo; **Multipass**, **Nix** ve **Docker/K3s** kullanarak standartlaştırılmış, uluslararasılaştırılmış ve modüler sanal geliştirme ortamı konfigürasyonlarını içerir. Farklı teknoloji yığınları arasında tutarlı bir kodlama ortamı sağlamak için tasarlanmıştır.

---

## 📂 Project Structure / Proje Yapısı

### 1. Simple Environment (`/simple`)
- **🇺🇸 EN:** Managed through manual config editing. Best for fixed, long-term environments.
- **🇹🇷 TR:** Manuel konfigürasyon düzenlemesiyle yönetilir. Sabit ve uzun vadeli ortamlar için en iyisidir.
- **Tools:** PHP, Node.js, Python, Git (Managed via `.virtual-dev-env/shell.nix`).

### 2. Complex Environment (`/complex`)
- **🇺🇸 EN:** Advanced orchestrator using CLI overrides. Change anything on-the-fly.
- **🇹🇷 TR:** CLI parametreleri ile yönetilen gelişmiş orkestratör. Her şeyi anlık olarak değiştirin.
- **Tools:** Dynamic PHP/Node versions, optional Databases (Redis, Postgres, MariaDB, SQLite).

### 3. Docker Environment (`/docker`)
- **🇺🇸 EN:** Container-based workflow with Docker Compose and local Kubernetes (K3s).
- **🇹🇷 TR:** Docker Compose ve yerel Kubernetes (K3s) destekli konteyner tabanlı çalışma akışı.
- **Tools:** Modular runtimes, DB Profiles, and K3s cluster management via `k3d`.

---

## 🚀 Quick Start / Hızlı Başlangıç

### Prerequisites / Önkoşullar
- **Multipass / Nix:** For VM and lightweight shells.
- **Docker / k3d:** For containerized and K8s environments.

### Usage / Kullanım

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

---

## 🛠 Features / Özellikler

| Feature / Özellik | Simple | Complex | Docker/K3s |
| :--- | :---: | :---: | :---: |
| **Nix Shell / VM** | ✅ | ✅ | ❌ (Docker) |
| **Variable Overrides** | ❌ (Manual) | ✅ (CLI) | ✅ (CLI) |
| **Database Profiles** | ❌ | ✅ | ✅ |
| **Kubernetes (K3s)** | ❌ | ❌ | ✅ |
| **Color UI / Help** | ✅ | ✅ | ✅ |
| **Architecture** | Config-First | Orchestrator-First | Container-First |

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
> Her klasör içinde `make help` komutunu kullanarak en güncel komutları ve aktif yapılandırma varsayılanlarınızı görebilirsiniz.
