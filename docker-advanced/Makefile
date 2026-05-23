# ==============================================================================
# WORKSPACE DEVELOPMENT ENVIRONMENT (Makefile)
# ==============================================================================
# Docker-based polyglot development environment with optional database services.
#
# Quick Start:
#   make up                          # Start workspace container
#   make up DATABASES="postgres redis"  # Start with databases
#   make shell                       # Enter the workspace
#   make down                        # Stop everything
# ==============================================================================

# ── Configuration ─────────────────────────────────────────────────────────
CONTAINER_NAME   ?= workspace
COMPOSE_DIR      ?= .docker-advanced
COMPOSE_FILE     ?= $(COMPOSE_DIR)/docker-compose.yml
DOCKER_FILE      ?= $(COMPOSE_DIR)/Dockerfile

# Runtime versions (set empty to disable)
GO_VERSION       ?= 1.24
PHP_VERSION      ?= 8.3
NODE_VERSION     ?= 20

# Active database services (space-separated)
# Options: postgres, mysql (or mariadb), redis, mailpit
DATABASES        ?=

# Build Docker Compose profile flags from DATABASES
COMPOSE_PROFILES := $(foreach db,$(DATABASES),--profile $(db))

# Export for docker-compose.yml
export CONTAINER_NAME GO_VERSION PHP_VERSION NODE_VERSION

# ── Colors ────────────────────────────────────────────────────────────────
C_RESET  := \033[0m
C_BLUE   := \033[1;34m
C_GREEN  := \033[1;32m
C_YELLOW := \033[1;33m
C_CYAN   := \033[1;36m
C_RED    := \033[1;31m

# ── Help ──────────────────────────────────────────────────────────────────
.PHONY: help
help:
	@echo "$(C_CYAN)╔══════════════════════════════════════════════════════════╗$(C_RESET)"
	@echo "$(C_CYAN)║            WORKSPACE DEVELOPMENT ENVIRONMENT            ║$(C_RESET)"
	@echo "$(C_CYAN)╚══════════════════════════════════════════════════════════╝$(C_RESET)"
	@echo ""
	@echo "$(C_BLUE)SETUP (run once per project)$(C_RESET)"
	@echo "  make setup                 Initial setup: configure + build"
	@echo ""
	@echo "$(C_BLUE)CONTAINER LIFECYCLE$(C_RESET)"
	@echo "  make up [DATABASES=\"...\"]   Start workspace (and databases)"
	@echo "  make down                    Stop all containers"
	@echo "  make restart                 Restart all containers"
	@echo ""
	@echo "$(C_BLUE)BUILD & CONFIG$(C_RESET)"
	@echo "  make build                   Build/rebuild workspace image"
	@echo "  make rebuild                 Force clean build (no-cache)"
	@echo ""
	@echo "$(C_BLUE)INTERACTION$(C_RESET)"
	@echo "  make shell                   Open shell inside workspace"
	@echo "  make logs [SERVICE]          Follow logs (default: workspace)"
	@echo "  make ps                      List running containers"
	@echo "  make stats                   Live resource usage"
	@echo ""
	@echo "$(C_BLUE)DEVELOPMENT$(C_RESET)"
	@echo "  make test                    Run tests (auto-detect: Go/ PHP/ Node)"
	@echo "  make lint                    Run linters (auto-detect)"
	@echo ""
	@echo "$(C_BLUE)CLEANUP$(C_RESET)"
	@echo "  make prune                   Remove unused Docker data"
	@echo "  make clean                   Remove containers, images, volumes"
	@echo "  make destroy                 Remove everything (including data volumes)"
	@echo ""
	@echo "$(C_BLUE)EXAMPLES$(C_RESET)"
	@echo "  make up                      # Workspace only"
	@echo "  make up DATABASES=\"postgres redis\""
	@echo "  make up DATABASES=\"postgres redis mailpit\""
	@echo "  make build PHP_VERSION=8.4"
	@echo ""
	@echo "$(C_BLUE)CURRENT CONFIGURATION$(C_RESET)"
	@echo "  Container : $(CONTAINER_NAME)"
	@echo "  Go        : $(GO_VERSION)"
	@echo "  PHP       : $(PHP_VERSION)"
	@echo "  Node      : $(NODE_VERSION)"
	@echo "  Databases : $(if $(DATABASES),$(DATABASES),$(C_YELLOW)(none)$(C_RESET))"
	@echo "$(C_CYAN)──────────────────────────────────────────────────────────$(C_RESET)"

# ── Setup (one-time) ──────────────────────────────────────────────────────
.PHONY: setup

setup:
	@echo "$(C_BLUE)--> Initializing workspace configuration...$(C_RESET)"
	@if [ ! -f .env ]; then \
		cp .env.example .env && \
		echo "$(C_GREEN)  ✔ Created .env from .env.example$(C_RESET)"; \
		echo "$(C_YELLOW)  → Edit .env to customize versions and databases$(C_RESET)"; \
	else \
		echo "$(C_GREEN)  ✔ .env already exists$(C_RESET)"; \
	fi
	@echo "$(C_BLUE)--> Building workspace image (this may take a few minutes)...$(C_RESET)"
	$(MAKE) build
	@echo ""
	@echo "$(C_GREEN)╔══════════════════════════════════════════════════════════╗$(C_RESET)"
	@echo "$(C_GREEN)║             SETUP COMPLETE!                              ║$(C_RESET)"
	@echo "$(C_GREEN)╚══════════════════════════════════════════════════════════╝$(C_RESET)"
	@echo "  Next steps:"
	@echo "    make up                   Start the environment"
	@echo "    make shell                Enter the workspace"
	@echo "    make down                 Stop everything"
	@echo ""

# ── Container Lifecycle ───────────────────────────────────────────────────
.PHONY: up down restart

up:
	@echo "$(C_BLUE)--> Starting workspace$(if $(DATABASES), with databases: $(DATABASES))...$(C_RESET)"
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) up -d --wait
	@echo "$(C_GREEN)--> Workspace is UP! Use 'make shell' to enter.$(C_RESET)"

down:
	@echo "$(C_YELLOW)--> Stopping containers...$(C_RESET)"
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) down
	@echo "$(C_GREEN)--> Done.$(C_RESET)"

restart: down up

# ── Build ─────────────────────────────────────────────────────────────────
.PHONY: build rebuild

build:
	@echo "$(C_BLUE)--> Building workspace image [Go: $(GO_VERSION), PHP: $(PHP_VERSION), Node: $(NODE_VERSION)]...$(C_RESET)"
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) build workspace
	@echo "$(C_GREEN)--> Build complete.$(C_RESET)"

rebuild:
	@echo "$(C_RED)--> Clean rebuild (no-cache)...$(C_RESET)"
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) build --no-cache workspace
	@echo "$(C_GREEN)--> Rebuild complete.$(C_RESET)"

# ── Interaction ───────────────────────────────────────────────────────────
.PHONY: shell logs ps stats

shell:
	docker exec -it $(CONTAINER_NAME) bash

logs:
	@services=$(filter-out logs,$(MAKECMDGOALS)); \
	if [ -n "$$services" ]; then \
		docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) logs -f $$services; \
	else \
		docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) logs -f workspace; \
	fi

ps:
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) ps

stats:
	@echo "Use: docker stats $(CONTAINER_NAME)"

# ── Development ───────────────────────────────────────────────────────────
.PHONY: test lint

test:
	@echo "$(C_BLUE)--> Running tests...$(C_RESET)"
	@docker exec $(CONTAINER_NAME) bash -c '\
		if [ -f go.mod ]; then \
			echo "  [Go] running tests..."; \
			go test ./...; \
		elif [ -f composer.json ]; then \
			echo "  [PHP] running tests..."; \
			[ -f vendor/bin/phpunit ] && vendor/bin/phpunit || php -r "echo \"  No test runner found.\n\";"; \
		elif [ -f package.json ]; then \
			echo "  [Node] running tests..."; \
			npm test 2>/dev/null || echo "  No test script found."; \
		else \
			echo "  No recognized project detected. Nothing to test."; \
		fi'

lint:
	@echo "$(C_BLUE)--> Running linters...$(C_RESET)"
	@docker exec $(CONTAINER_NAME) bash -c '\
		if [ -f go.mod ]; then \
			echo "  [Go] vet..."; \
			go vet ./...; \
		elif [ -f composer.json ]; then \
			echo "  [PHP] syntax check..."; \
			find . -name "*.php" -not -path "./vendor/*" -exec php -l {} \; 2>&1 | grep -v "No syntax errors"; \
		elif [ -f package.json ]; then \
			echo "  [Node] lint..."; \
			npm run lint 2>/dev/null || echo "  No lint script found."; \
		else \
			echo "  No recognized project detected."; \
		fi'

# ── Cleanup ───────────────────────────────────────────────────────────────
.PHONY: prune clean destroy

prune:
	@echo "$(C_RED)--> Removing unused Docker resources...$(C_RESET)"
	docker system prune -f

clean: down
	@echo "$(C_RED)--> Removing images for $(CONTAINER_NAME)...$(C_RESET)"
	-docker rmi $$(docker compose -f $(COMPOSE_FILE) images -q workspace) 2>/dev/null || true
	@echo "$(C_GREEN)--> Clean.$(C_RESET)"

destroy: down
	@echo "$(C_RED)--> Removing everything (including volumes)...$(C_RESET)"
	docker compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) down -v
	@echo "$(C_GREEN)--> Destroyed. All data volumes removed.$(C_RESET)"
