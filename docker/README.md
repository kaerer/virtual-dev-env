# 🐳 Docker Development Environment (Container-First)

Container-based development environment using **Docker Compose** and **K3s (k3d)**. Modular runtimes, database profiles, and local Kubernetes cluster management. Perfect for teams that want consistent, reproducible dev environments.

---

## 📋 Prerequisites

- **Docker** — [docs.docker.com/get-docker](https://docs.docker.com/get-docker/)
- **k3d** (optional, for K3s) — `curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash`

---

## 🚀 Quick Start

```bash
# 1. Copy into your project
cp -r path/to/docker/ your-project/
cd your-project/docker

# 2. One-time setup
make setup
# → Edit .env to customize versions and databases

# 3. Build and start
make build
make up

# 4. Enter the app container
make shell

# 5. When done
make down
```

---

## ⚙️ Configuration

### Via `.env` (recommended)

Run `make setup` — creates `.env` from `.env.example`. Edit once:

```bash
# .env
PHP_VER=8.3
NODE_VER=20
DATABASES=redis postgres
```

After editing, `make build && make up` picks up your settings automatically.

### Via CLI (override without editing)

```bash
make build PHP_VER=8.3 NODE_VER=20
make up DATABASES="redis postgres mariadb"
make up DATABASES=""    # No databases
```

### Configuration reference

| Variable | Default | Options | Description |
|----------|---------|---------|-------------|
| `CONTAINER_NAME` | `dev-app` | any string | Docker container name |
| `CLUSTER_NAME` | `dev-cluster` | any string | K3s cluster name |
| `PHP_VER` | `8.2` | `8.1`–`8.4` (empty to disable) | PHP version |
| `NODE_VER` | `18` | `16`–`22` (empty to disable) | Node.js major version |
| `DATABASES` | `redis` | Space-separated: `redis` `postgres` `mariadb` | Active database services |

---

## 📚 Commands

```bash
make help                # Show this panel

# Setup
make setup               # Create .env from .env.example

# Container Lifecycle
make up                  # Start containers
make down                # Stop and remove containers
make restart             # Restart containers

# Build
make build               # Build Docker images
make rebuild             # Clean build (no-cache)

# Interaction
make shell               # Open bash in app container
make logs                # Follow logs
make ps                  # List containers
make stats               # Resource usage

# Kubernetes (K3s)
make k3s-up              # Create local K3s cluster
make k3s-down            # Delete cluster
make k3s-status          # Show cluster status
make k3s-shell           # Watch pods

# Cleanup
make prune               # Remove unused Docker data
make clean               # Remove containers + images

# Deployment
make create-deployment   # Package as .zip
```

---

## 🏗️ Architecture

### File Structure

```
your-project/
├── ...
└── docker/                            # Copy this folder
    ├── Makefile
    ├── README.md
    ├── .env.example
    ├── .env                           # Your config (created by make setup)
    └── .virtual-dev-env/
        ├── Dockerfile                 # Multi-runtime container image
        ├── docker-compose.yml         # Service orchestration with profiles
        ├── .dockerignore
        └── k3s/
            └── deployment.yaml        # K8s deployment + service manifest
```

---

## 💡 Example Workflows

```bash
# LEMP stack (PHP + Nginx + MariaDB)
make build PHP_VER=8.3
make up DATABASES="mariadb"

# Go API + Redis (after editing Dockerfile to add Go)
make up DATABASES="redis"

# Full stack
make build PHP_VER=8.3 NODE_VER=20
make up DATABASES="redis postgres mariadb"
```

---

## 🔧 Troubleshooting

**Container exits immediately**
→ The Dockerfile uses `CMD ["tail", "-f", "/dev/null"]` to keep it running.

**Port conflict**
→ Edit `docker-compose.yml` to change host port mappings.

**k3d cluster creation fails**
→ Run `k3d cluster delete dev-cluster` first if it already exists.

---

> [!TIP]
> Run `make help` to see current defaults and available commands.
> Set preferences once in `.env`, then just use `make build` and `make up`.
