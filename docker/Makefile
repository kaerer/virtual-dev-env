# ==============================================================================
# DOCKER DEVELOPMENT ENVIRONMENT ORCHESTRATOR (Makefile)
# ==============================================================================

# 1. CONFIGURATION & VARIABLES
# ------------------------------------------------------------------------------
CONTAINER_NAME   ?= dev-app
CLUSTER_NAME     ?= dev-cluster
# Versions can be empty to disable installation (e.g., PHP_VER := )
PHP_VER          ?= 8.2
NODE_VER         ?= 18

# Active Database List
# Possible Options: redis, postgres, mariadb
# Example: DATABASES="redis postgres"
DATABASES        ?= redis

COMPOSE_FILE     ?= .virtual-dev-env/docker-compose.yml
DOCKER_FILE      ?= .virtual-dev-env/Dockerfile
DEPLOY_IGNORE    ?= .virtual-dev-env/.dockerignore
DEPLOYMENT_FILE  ?= deployment.zip

# Map DATABASES to Docker Compose Profiles
# This allows starting only the needed containers.
COMPOSE_PROFILES := $(foreach db,$(DATABASES),--profile $(db))

# Export variables for Docker Compose
export CONTAINER_NAME
export PHP_VER
export NODE_VER

# Terminal Color Codes (Professional UX)
C_RESET          := \033[0m
C_BLUE           := \033[1;34m
C_GREEN          := \033[1;32m
C_YELLOW         := \033[1;33m
C_RED            := \033[1;31m
C_CYAN           := \033[1;36m
C_SUCCESS        := \033[1;32m

# 2. TARGET DEFINITIONS (.PHONY)
# ------------------------------------------------------------------------------
.PHONY: help up down restart build rebuild shell logs ps stats prune clean info create-deployment \
        k3s-up k3s-down k3s-status k3s-shell

# 3. HELP AND PANEL INTERFACE
# ------------------------------------------------------------------------------
help:
	@echo "$(C_CYAN)========================================================================$(C_RESET)"
	@echo "$(C_CYAN)                 DOCKER ENVIRONMENT SYSTEM CONTROL PANEL                    $(C_RESET)"
	@echo "$(C_CYAN)========================================================================$(C_RESET)"
	@echo "$(C_BLUE)1. CONTAINER LIFECYCLE$(C_RESET)"
	@echo "   make up               : Starts the containers in background."
	@echo "   make down             : Stops and removes the containers."
	@echo "   make restart          : Restarts the containers."
	@echo ""
	@echo "$(C_BLUE)2. BUILD MANAGEMENT$(C_RESET)"
	@echo "   make build            : Builds the Docker images."
	@echo "   make rebuild          : Forces a clean build (no-cache)."
	@echo ""
	@echo "$(C_BLUE)3. DYNAMIC USAGE EXAMPLES$(C_RESET)"
	@echo "   make build PHP_VER=8.3 NODE_VER=20"
	@echo "   make up DATABASES=\"redis postgres mariadb\""
	@echo "   make up DATABASES=\"\"                 # No databases"
	@echo ""
	@echo "$(C_BLUE)4. INTERACTION & DEBUGGING$(C_RESET)"
	@echo "   make shell            : Opens a bash shell inside the app container."
	@echo "   make logs             : Follows the container logs."
	@echo "   make ps               : Lists active containers."
	@echo "   make stats            : Displays live resource usage statistics."
	@echo ""
	@echo "$(C_BLUE)5. SYSTEM CLEANUP$(C_RESET)"
	@echo "   make prune            : Removes unused Docker data (careful!)."
	@echo "   make clean            : Removes all containers and images related to this project."
	@echo ""
	@echo "$(C_BLUE)6. DEPLOYMENT$(C_RESET)"
	@echo "   make create-deployment: Generates a zip package using $(DEPLOY_IGNORE)."
	@echo ""
	@echo "$(C_BLUE)7. KUBERNETES (K3s via k3d)$(C_RESET)"
	@echo "   make k3s-up           : Deploys a local K3s cluster using Docker."
	@echo "   make k3s-down         : Deletes the local K3s cluster."
	@echo "   make k3s-status       : Shows cluster nodes and status."
	@echo ""
	@echo "$(C_BLUE)8. CURRENT CONFIGURATION (Defaults)$(C_RESET)"
	@echo "   Container Name : $(CONTAINER_NAME)"
	@echo "   Cluster Name   : $(CLUSTER_NAME)"
	@echo "   PHP Ver        : $(PHP_VER)"
	@echo "   Node Ver       : $(NODE_VER)"
	@echo "   Databases      : $(DATABASES)"
	@echo "$(C_CYAN)========================================================================$(C_RESET)"

# 4. TARGET IMPLEMENTATIONS
# ------------------------------------------------------------------------------

up:
	@echo "$(C_BLUE)--> Starting Docker environment (Active Databases: '$(DATABASES)')...$(C_RESET)"
	docker-compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) up -d
	@echo "$(C_SUCCESS)--> Environment is UP!$(C_RESET)"

down:
	@echo "$(C_YELLOW)--> Stopping and removing containers...$(C_RESET)"
	docker-compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) down
	@echo "$(C_SUCCESS)--> Environment is DOWN.$(C_RESET)"

restart: down up

build:
	@echo "$(C_BLUE)--> Building images [PHP: $(PHP_VER), Node: $(NODE_VER)]...$(C_RESET)"
	docker-compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) build

rebuild:
	@echo "$(C_RED)--> Performing a clean rebuild (no-cache)...$(C_RESET)"
	docker-compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) build --no-cache

shell:
	@echo "$(C_BLUE)--> Entering shell in container: $(CONTAINER_NAME)...$(C_RESET)"
	docker exec -it $(CONTAINER_NAME) bash

logs:
	docker-compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) logs -f

ps:
	docker-compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) ps

stats:
	docker stats $(CONTAINER_NAME)

prune:
	@echo "$(C_RED)--> Removing unused Docker resources...$(C_RESET)"
	docker system prune -f

clean: down
	@echo "$(C_RED)--> Removing images for $(CONTAINER_NAME)...$(C_RESET)"
	-docker rmi $$(docker-compose -f $(COMPOSE_FILE) images -q) 2>/dev/null || true

info:
	@echo "$(C_CYAN)=== DOCKER SYSTEM STATUS ===$(C_RESET)"
	docker-compose -f $(COMPOSE_FILE) $(COMPOSE_PROFILES) version
	docker inspect $(CONTAINER_NAME) --format '{{.State.Status}}' 2>/dev/null || echo "$(C_RED)Container not running.$(C_RESET)"

create-deployment:
	@echo "$(C_BLUE)--> Preparing deployment package ($(DEPLOYMENT_FILE))...$(C_RESET)"
	@rm -f $(DEPLOYMENT_FILE)
	@if [ ! -f $(DEPLOY_IGNORE) ]; then \
		zip -r $(DEPLOYMENT_FILE) . ; \
	else \
		zip -r $(DEPLOYMENT_FILE) . -x@$(DEPLOY_IGNORE) ; \
	fi
	@echo "$(C_SUCCESS)--> Deployment package created: $(DEPLOYMENT_FILE)$(C_RESET)"

# 5. KUBERNETES (K3s via k3d) IMPLEMENTATION
# ------------------------------------------------------------------------------

k3s-up:
	@echo "$(C_BLUE)--> Creating K3s Cluster: $(CLUSTER_NAME)...$(C_RESET)"
	@k3d cluster create $(CLUSTER_NAME) --api-port 6443 --servers 1 --agents 2 --port 8080:80@loadbalancer --wait || echo "$(C_YELLOW)Cluster might already exist.$(C_RESET)"
	@echo "$(C_SUCCESS)--> Cluster $(CLUSTER_NAME) is ready!$(C_RESET)"
	@echo "$(C_BLUE)--> Kubeconfig is automatically updated.$(C_RESET)"

k3s-down:
	@echo "$(C_RED)--> Deleting K3s Cluster: $(CLUSTER_NAME)...$(C_RESET)"
	k3d cluster delete $(CLUSTER_NAME)
	@echo "$(C_SUCCESS)--> Cluster deleted.$(C_RESET)"

k3s-status:
	@echo "$(C_CYAN)=== K3S CLUSTER STATUS ===$(C_RESET)"
	kubectl get nodes
	@echo ""
	k3d cluster list

k3s-shell:
	@echo "$(C_BLUE)--> Opening watch on cluster pods...$(C_RESET)"
	kubectl get pods -A -w
