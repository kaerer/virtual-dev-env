# 🚀 Docker Advanced Development Environment

A modern, Docker-based polyglot development environment. One command starts everything you need — workspace container with **Go**, **PHP**, **Node.js**, **Python**, plus optional databases (PostgreSQL, MySQL/MariaDB, Redis).

**Zero host dependencies beyond Docker.** Consistent across macOS, Linux, Windows.

---

## 📋 Prerequisites

- **Docker** (24+) — [docs.docker.com/get-docker](https://docs.docker.com/get-docker/)
- **Docker Compose** (v2, included with Docker Desktop / Docker Engine)

Verify:

```bash
docker --version
docker compose version
```

---

## 🚀 Quick Start

```bash
# 1. Copy docker-advanced into your project
cp -r path/to/docker-advanced/ your-project/
cd your-project/docker-advanced

# 2. One-time setup (creates .env + builds image)
make setup

# 3. Start the environment
make up

# 4. Enter the workspace
make shell

# You now have Go, PHP, Node, Python ready inside

# 5. When done
exit      # Exit the container shell
make down # Stop everything
```

After first `make setup`, your daily workflow is just:

```bash
make up      # Start
make shell   # Develop
make down    # Stop
```

---

## ⚙️ Configuration

### One-time setup with `.env`

Run `make setup` — it creates a `.env` file from `.env.example`. Edit it once:

```bash
# .env — edit this file to set your preferences
GO_VERSION=1.24
PHP_VERSION=8.3
NODE_VERSION=20
DATABASES=postgres redis
```

After editing `.env`, run `make build` once to rebuild with your settings.

### Runtimes

| Variable | Default | Description |
|----------|---------|-------------|
| `GO_VERSION` | `1.24` | Go version (empty to disable) |
| `PHP_VERSION` | `8.3` | PHP version: `8.1`, `8.2`, `8.3`, `8.4` (empty to disable) |
| `NODE_VERSION` | `20` | Node.js major version: `18`, `20`, `22` (empty to disable) |
| `CONTAINER_NAME` | `workspace` | Docker container name |

Override via CLI (no `.env` edit needed):

```bash
make build GO_VERSION=1.23 PHP_VERSION=8.4 NODE_VERSION=22
```

**Disable a runtime** by setting it empty:

```bash
make build GO_VERSION=1.24 PHP_VERSION= NODE_VERSION=
# → Container has Go only, no PHP, no Node
```

### Databases

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASES` | *(none)* | Space-separated: `postgres`, `mysql` (or `mariadb`), `redis`, `mailpit` |
| `DB_DRIVER` | `postgres` | Primary database driver (`postgres` / `mysql`) |
| `DB_NAME` | `devdb` | Default database name |
| `DB_USER` | `devuser` | Default database user |
| `DB_PASSWORD` | `devpass` | Default database password |
| `PG_PORT` | `5432` | PostgreSQL host port |
| `MYSQL_PORT` | `3306` | MySQL/MariaDB host port |
| `REDIS_PORT` | `6379` | Redis host port |
| `MAILPIT_SMTP_PORT` | `1025` | Mailpit SMTP port |
| `MAILPIT_UI_PORT` | `8025` | Mailpit web UI port |

Examples:

```bash
# PostgreSQL + Redis
make up DATABASES="postgres redis"

# MySQL/MariaDB + Redis
make up DATABASES="mysql redis"

# PostgreSQL + Redis + Mailpit (email testing)
make up DATABASES="postgres redis mailpit"
# Mailpit UI: http://localhost:8025

# No databases (workspace only)
make up DATABASES=""
```

---

## 📚 Commands

```bash
make help        # Show this panel

# Setup (run once)
make setup       # Configure .env + build image

# Lifecycle
make up          # Start workspace
make down        # Stop all containers
make restart     # Restart all

# Build
make build       # Build workspace image
make rebuild     # Clean rebuild (no-cache)

# Interact
make shell       # Open bash in workspace
make logs        # Follow workspace logs
make logs mysql  # Follow a specific service log
make ps          # List running containers
make stats       # Live resource usage

# Dev
make test        # Auto-detect and run tests (Go/PHP/Node)
make lint        # Auto-detect and run linters

# Cleanup
make prune       # Remove unused Docker data
make clean       # Remove containers + images
make destroy     # Remove everything including volumes
```

---

## 🆚 Workspace vs Docker Template

Both are Docker-based, but serve different needs:

| Aspect | `docker/` (LEMP) | `docker-advanced/` (Polyglot) |
|--------|:---:|:---:|
| **Runtimes** | PHP + Node | Go + PHP + Node + Python |
| **Web Server** | Nginx (included) | Not included (bring your own) |
| **Databases** | MariaDB + Postgres + Redis | MariaDB + Postgres + Redis |
| **DB Profiles** | ✅ Compose profiles | ✅ Compose profiles |
| **Version Override** | ✅ PHP, Node | ✅ Go, PHP, Node |
| **Disable Runtime** | ✅ Set empty | ✅ Set empty |
| **Hot-Reload** | ❌ | ✅ Air (Go) |
| **Xdebug** | ❌ | ✅ Pre-installed |
| **Composer** | ✅ Installed in image | ✅ Installed in image |
| **Yarn / pnpm** | ❌ | ✅ Pre-installed |
| **Auto test/lint** | ❌ | ✅ `make test`, `make lint` |
| **Email Testing** | ❌ | ✅ Mailpit |
| **Healthchecks** | ❌ | ✅ All services |
| **Use Case** | PHP web apps with Nginx | Polyglot dev (Go services, APIs, CLIs) |

**Choose `docker-advanced/` if:** You work with Go, need multiple runtimes, want hot-reload, or want a modern dev container experience.

**Choose `docker/` if:** You need a traditional LEMP stack with Nginx + PHP-FPM out of the box.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Host Machine                         │
│  ┌──────────────────────────────────────────────────┐   │
│  │             workspace-net (bridge)                 │   │
│  │  ┌──────────┐  ┌──────────┐  ┌────────────────┐  │   │
│  │  │ Postgres │  │  MySQL   │  │   Mailpit      │  │   │
│  │  │ :5432    │  │ :3306    │  │ :1025 (SMTP)   │  │   │
│  │  │          │  │          │  │ :8025 (Web UI)  │  │   │
│  │  └──────────┘  └──────────┘  └────────────────┘  │   │
│  │  ┌──────────┐                                     │   │
│  │  │  Redis   │                                     │   │
│  │  │ :6379    │                                     │   │
│  │  └──────────┘                                     │   │
│  │  ┌──────────────────────────────────────────────┐ │   │
│  │  │              Workspace Container               │ │   │
│  │  │  Go  │  PHP+Composer  │  Node+npm  │ Python  │ │   │
│  │  │  Air │  Xdebug        │  Yarn/pnpm │ Git     │ │   │
│  │  └──────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### File Structure

```
your-project/
├── ... (your code)
└── docker-advanced/                   # Copy this folder into your project
    ├── Makefile                      # Entry point (all commands)
    ├── README.md                     # This file
    ├── .env.example                  # Template for configuration
    ├── .env                          # Your config (created by make setup)
    └── .docker-advanced/
        ├── Dockerfile                # Workspace container image
        ├── docker-compose.yml        # Service orchestration
        └── .dockerignore             # Build exclusions
```

---

## 💡 Example Workflows

### Go API with PostgreSQL

```bash
# 1. Setup
make setup
# → Edit .env: DATABASES=postgres

# 2. Start
make up

# 3. Enter workspace
make shell

# 4. Initialize Go project
cd /workspace
go mod init github.com/you/myapi
# ... develop your API ...

# 5. Test
make test

# 6. Done
exit
make down
```

### PHP Laravel with MySQL

```bash
make setup
# → Edit .env: PHP_VERSION=8.3 DATABASES=mysql DB_NAME=laravel

make up
make shell

cd /workspace
composer create-project laravel/laravel .
# ... develop ...

exit
make down
```

### Go-only CLI Tool (no databases)

```bash
make setup
# → Edit .env: PHP_VERSION= NODE_VERSION= DATABASES=

make up
make shell

cd /workspace
go mod init github.com/you/mytool
# ... develop CLI ...
go build -o mytool .

exit
make down
```

### Node.js + Redis

```bash
make setup
# → Edit .env: GO_VERSION= PHP_VERSION= NODE_VERSION=20 DATABASES=redis

make build   # Rebuild with new config
make up
make shell

cd /workspace
npm init
npm install redis
# ... develop ...

exit
make down
```

---

## 🛠️ Development Tips

### Go development with hot-reload

```bash
# Inside the workspace
cd /workspace/myapp
go install github.com/air-verse/air@latest
air init       # Creates .air.toml
air            # Starts with hot-reload
```

### PHP with Xdebug

Xdebug is pre-installed. Configure your IDE to listen on port 9000.

```bash
php -d xdebug.mode=debug -d xdebug.client_host=host.docker.internal script.php
```

### Database connection strings

The workspace container has these environment variables pre-set:

```env
# PostgreSQL
DATABASE_URL=postgres://devuser:devpass@postgres:5432/devdb

# MySQL
DATABASE_URL=mysql://devuser:devpass@mysql:3306/devdb

# Redis
REDIS_URL=redis://redis:6379/0

# Mailpit (SMTP)
MAILER_DSN=smtp://mailpit:1025
```

### Using `.env` for project config

The `.env` file is git-ignored by default (add `.env` to your project's `.gitignore`). It keeps secrets and machine-specific config out of version control.

---

## 🔧 Troubleshooting

**Permission denied writing to /workspace**
→ The container runs as `developer` user (UID 1000). Ensure your host files have matching permissions.

**Port conflict**
→ Change host ports via `.env`: `PG_PORT=5433 MYSQL_PORT=3307 REDIS_PORT=6380`

**Container exits immediately**
→ The workspace uses `sleep infinity` as entrypoint. Check logs: `make logs`

**Build fails with platform error**
→ ARM64 (Apple Silicon) is auto-detected for Go downloads. Ensure Docker is using Rosetta if needed.

**"docker compose" not found**
→ Use `docker-compose` (with hyphen). If neither works, install Docker Compose v2.

---

> [!TIP]
> 1. `make setup` — one-time config + build
> 2. `make up` — start
> 3. `make shell` — develop
> 4. `make down` — stop
>
> Copy this folder into any project for instant development environment.
