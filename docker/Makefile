# ==============================================================================
# DOCKER DEVELOPMENT ENVIRONMENT ORCHESTRATOR (Makefile)
# ==============================================================================
# Container-based development with Docker Compose and local Kubernetes (K3s).
# Modular runtimes, database profiles, and K3s cluster management.
#
# Quick Start:
#   make setup            # One-time: create .env
#   make build            # Build container image
#   make up               # Start containers
#   make shell            # Enter the app container
# ==============================================================================

# ── Load .env if exists ──────────────────────────────────────────────────
ifneq (,$(wildcard .env))
    include .env
    export
endif

# ── Variables ────────────────────────────────────────────────────────────
CONTAINER_NAME   ?= dev-app
CLUSTER_NAME     ?= dev-cluster

# Runtime versions (set empty to disable)
PHP_VER          ?= 8.2
NODE_VER         ?= 18

# Active databases (space-separated: redis, postgres, mariadb)
DATABASES        ?= redis

# Paths
COMPOSE_FILE     ?= .virtual-dev-env/docker-compose.yml
DOCKER_FILE      ?= .virtual-dev-env/Dockerfile
DEPLOY_IGNORE    ?= .virtual-dev-env/.dockerignore
DEPLOYMENT_FILE  ?= deployment.zip

# Build Compose profile flags from DATABASES
COMPOSE_PROFILES := $(foreach db,$(DATABASES),--profile $(db))

# Export for docker-compose.yml
export CONTAINER_NAME PHP_VER NODE_VER

# ── Colors ────────────────────────────────────────────────────────────────
C_RESET  := \033[0m
C_BLUE   := \033[1;34m
C_GREEN  := \033[1;32m
C_YELLOW := \033[1;33m
C_CYAN   := \033[1;36m
C_RED    := \033[1;31m

# ── Targets ──────────────────────────────────────────────────────────────
.PHONY: help setup up down restart build rebuild shell logs ps stats \
        prune clean info create-deployment \
        k3s-up k3s-down k3s-status k3s-shell

# ── Help ──────────────────────────────────────────────────────────────────
help:
	@echo "$(C_CYAN)╔══════════════════════════════════════════════════════════╗$(C_RESET)"
	@echo "$(C_CYAN)║           DOCKER DEVELOPMENT ENVIRONMENT                  ║$(C_RESET)"
	@echo "$(C_CYAN)╚══════════════════════════════════════════════════════════╝$(C_RESET)"
	@echo ""
	@echo "$(C_BLUE)SETUP (run once)$(C_RESET)"
	@echo "  make setup               Create .env from .env.example"
	@echo ""
	@echo "$(C_BLUE)CONTAINER LIFECYCLE$(C_RESET)"
	@echo "  make up [DATABASES=...]  Start containers"
	@echo "  make down                Stop and remove containers"
	@echo "  make restart             Restart containers"
	@echo ""
	@echo "$(C_BLUE)BUILD$(C_RESET)"
	@echo "  make build               Build Docker images"
	@echo "  make rebuild             Clean build (no-cache)"
	@echo ""
	@echo "$(C_BLUE)INTERACTION$(C_RESET)"
	@echo "  make shell               Open bash in app container"
	@echo "  make logs                Follow container logs"
	@echo "  make ps                  List active containers"
	@echo "  make stats               Live resource usage"
	@echo ""
	@echo "$(C_BLUE)KUBERNETES (K3s via k3d)$(C_RESET)"
	@echo "  make k3s-up              Create local K3s cluster"
	@echo "  make k3s-down            Delete cluster"
	@echo "  make k3s-status          Show cluster status"
	@echo "  make k3s-shell           Watch cluster pods"
	@echo ""
	@echo "$(C_BLUE)CLEANUP$(C_RESET)"
	@echo "  make prune               Remove unused Docker data"
	@echo "  make clean               Remove containers + images"
	@echo ""
	@echo "$(C_BLUE)DEPLOYMENT & INFO$(C_RESET)"
	@echo "  make info                Show Docker status"
	@echo "  make create-deployment   Package project as .zip"
	@echo ""
	@echo "$(C_BLUE)EXAMPLES$(C_RESET)"
	@echo "  make build PHP_VER=8.3 NODE_VER=20"
	@echo "  make up DATABASES=\"redis postgres mariadb\""
	@echo ""
	@echo "$(C_BLUE)CURRENT CONFIG$(C_RESET)"
	@echo "  PHP: $(PHP_VER) | Node: $(NODE_VER) | DBs: $(if $(DATABASES),$(DATABASES),$(C_YELLOW)(none)$(C_RESET))"
	@echo "$(C_CYAN)──────────────────────────────────────────────────────────$(C_RESET)"

# ── Setup (one-time) ──────────────────────────────────────────────────────
setup:
	@echo "$(C_BLUE)--> Initializing configuration...$(C_RESET)"
	@if [ ! -f .env ]; then \
		cp .env.example .env && \
		echo "$(C_GREEN)  ✔ Created .env from .env.example$(C_RESET)" && \
		echo "$(C_YELLOW)  → Edit .env to customize versions and databases$(C_RESET)"; \
	else \
		echo "$(C_GREEN)  ✔ .env already exists$(C_RESET)"; \
	fi
	@echo ""
	@echo "$(C_GREEN)Setup complete. Next steps:$(C_RESET)"
	@echo "  make build               # Build container image"
	@echo "  make up                  # Start containers"
	@echo "  make shell               # Enter the app container"
	@echo ""

# ── Container Lifecycle ───────────────────────────────────────────────────
up:
	@echo "$(C_BLUE)--> Starting Docker environment$(if $(DATABASES), [DBs: $(DATABASES)])...$(C_RESET)"
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) up -d
	@echo "$(C_GREEN)--> Environment is UP!$(C_RESET)"

down:
	@echo "$(C_YELLOW)--> Stopping containers...$(C_RESET)"
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) down
	@echo "$(C_GREEN)--> Done.$(C_RESET)"

restart: down up

# ── Build ─────────────────────────────────────────────────────────────────
build:
	@echo "$(C_BLUE)--> Building images [PHP: $(PHP_VER), Node: $(NODE_VER)]...$(C_RESET)"
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) build

rebuild:
	@echo "$(C_RED)--> Clean rebuild (no-cache)...$(C_RESET)"
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) build --no-cache

# ── Interaction ───────────────────────────────────────────────────────────
shell:
	@echo "$(C_BLUE)--> Entering $(CONTAINER_NAME)...$(C_RESET)"
	docker exec -it $(CONTAINER_NAME) bash

logs:
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) logs -f

ps:
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) ps

stats:
	docker stats $(CONTAINER_NAME)

# ── Cleanup ───────────────────────────────────────────────────────────────
prune:
	@echo "$(C_RED)--> Removing unused Docker resources...$(C_RESET)"
	docker system prune -f

clean: down
	@echo "$(C_RED)--> Removing images for $(CONTAINER_NAME)...$(C_RESET)"
	-docker rmi $$(docker compose -f $(COMPOSE_FILE) images -q) 2>/dev/null || true

info:
	@echo "$(C_CYAN)=== DOCKER STATUS ===$(C_RESET)"
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) version
	docker inspect $(CONTAINER_NAME) --format '{{.State.Status}}' 2>/dev/null || echo "$(C_YELLOW)Container not running.$(C_RESET)"

# ── Deployment ────────────────────────────────────────────────────────────
create-deployment:
	@echo "$(C_BLUE)--> Creating deployment package ($(DEPLOYMENT_FILE))...$(C_RESET)"
	@rm -f $(DEPLOYMENT_FILE)
	@if [ ! -f $(DEPLOY_IGNORE) ]; then \
		echo "$(C_YELLOW)  ⚠ $(DEPLOY_IGNORE) not found, including all files...$(C_RESET)" && \
		zip -r $(DEPLOYMENT_FILE) .; \
	else \
		echo "$(C_GREEN)  ✔ Using $(DEPLOY_IGNORE) to exclude files$(C_RESET)" && \
		zip -r $(DEPLOYMENT_FILE) . -x@$(DEPLOY_IGNORE); \
	fi
	@echo "$(C_GREEN)--> Created: $(DEPLOYMENT_FILE)$(C_RESET)"

# ── Kubernetes (K3s via k3d) ──────────────────────────────────────────────
k3s-up:
	@echo "$(C_BLUE)--> Creating K3s cluster: $(CLUSTER_NAME)...$(C_RESET)"
	@k3d cluster create $(CLUSTER_NAME) --api-port 6443 --servers 1 --agents 2 --port 8080:80@loadbalancer --wait || echo "$(C_YELLOW)Cluster might already exist.$(C_RESET)"
	@echo "$(C_GREEN)--> Cluster ready!$(C_RESET)"

k3s-down:
	@echo "$(C_RED)--> Deleting cluster: $(CLUSTER_NAME)...$(C_RESET)"
	k3d cluster delete $(CLUSTER_NAME)
	@echo "$(C_GREEN)--> Deleted.$(C_RESET)"

k3s-status:
	@echo "$(C_CYAN)=== K3S CLUSTER ===$(C_RESET)"
	kubectl get nodes
	@echo ""
	k3d cluster list

k3s-shell:
	@echo "$(C_BLUE)--> Watching cluster pods...$(C_RESET)"
	kubectl get pods -A -w
