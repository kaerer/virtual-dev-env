# ==============================================================================
# COMPLEX DEVELOPMENT ENVIRONMENT ORCHESTRATOR (Makefile)
# ==============================================================================
# Dynamic, parameterized environment using Multipass and Nix Shell.
# Override PHP/Node versions and databases on-the-fly via CLI or .env.
#
# Quick Start:
#   make setup              # One-time: create .env, show instructions
#   make n-shell            # Open Nix shell with custom runtimes
#   make setup-vm           # Create VM with selected runtimes and DBs
#   make vm-shell           # SSH into VM
# ==============================================================================

# ── Load .env if exists ──────────────────────────────────────────────────
ifneq (,$(wildcard .env))
    include .env
    export
endif

# ── Variables ────────────────────────────────────────────────────────────
OS               := $(shell uname -s)

# Virtual Machine
VM_NAME          ?= dev-box
VM_CPUS          ?= 2
VM_MEM           ?= 2G
VM_DISK          ?= 15G
VM_LOCAL_DIR     ?= .
VM_REMOTE_DIR    ?= /home/ubuntu/project-workspace
CLOUD_INIT_TPL   ?= .virtual-dev-env/multipass-init.yaml.tpl
CLOUD_INIT_OUT   ?= /tmp/virtual-dev-env-cloud-init.yaml

# Nix
NIX_FILE         ?= .virtual-dev-env/shell.nix

# Runtimes (set empty to disable)
PHP_VER          ?= php82
NODE_VER         ?= nodejs_18

# Databases (space-separated: redis, postgres, mariadb, sqlite)
DATABASES        ?= redis sqlite

# Deployment
DEPLOYMENT_FILE  ?= deployment.zip
DEPLOY_IGNORE    ?= .virtual-dev-env/.deployignore

# Convert space-separated DATABASES to Nix array: [ "redis" "sqlite" ]
NIX_DB_ARRAY     := [ $(foreach db,$(DATABASES),\"$(db)\") ]

# ── Colors ────────────────────────────────────────────────────────────────
C_RESET  := \033[0m
C_BLUE   := \033[1;34m
C_GREEN  := \033[1;32m
C_YELLOW := \033[1;33m
C_CYAN   := \033[1;36m
C_RED    := \033[1;31m

# ── Targets ──────────────────────────────────────────────────────────────
.PHONY: help setup install-deps install-nix install-multipass info \
        n-shell nix-clean nix-update \
        setup-vm vm-shell vm-start vm-stop vm-restart vm-info vm-mount vm-unmount vm-purge \
        create-deployment

# ── Help ──────────────────────────────────────────────────────────────────
help:
	@echo "$(C_CYAN)╔══════════════════════════════════════════════════════════╗$(C_RESET)"
	@echo "$(C_CYAN)║        COMPLEX DEVELOPMENT ENVIRONMENT                    ║$(C_RESET)"
	@echo "$(C_CYAN)╚══════════════════════════════════════════════════════════╝$(C_RESET)"
	@echo ""
	@echo "$(C_BLUE)SETUP (run once)$(C_RESET)"
	@echo "  make setup               Create .env from .env.example"
	@echo ""
	@echo "$(C_BLUE)SYSTEM$(C_RESET)"
	@echo "  make install-deps        Install Nix + Multipass"
	@echo "  make install-nix         Install Nix package manager"
	@echo "  make install-multipass   Install Multipass"
	@echo "  make info                System status report"
	@echo ""
	@echo "$(C_BLUE)NIX SHELL$(C_RESET)"
	@echo "  make n-shell             Open Nix shell with selected runtimes"
	@echo "  make nix-clean           Remove old Nix packages"
	@echo "  make nix-update          Update Nix channels"
	@echo ""
	@echo "$(C_BLUE)MULTIPASS VM$(C_RESET)"
	@echo "  make setup-vm            Create VM with dynamic runtimes and DBs"
	@echo "  make vm-shell            SSH into VM"
	@echo "  make vm-start/stop       Start / Stop VM"
	@echo "  make vm-restart          Restart VM"
	@echo "  make vm-info             VM resource usage and IP"
	@echo "  make vm-mount/unmount    Mount / unmount host folder"
	@echo "  make vm-purge            Delete VM permanently"
	@echo ""
	@echo "$(C_BLUE)DEPLOYMENT$(C_RESET)"
	@echo "  make create-deployment   Package project as .zip"
	@echo ""
	@echo "$(C_BLUE)CURRENT CONFIG$(C_RESET)"
	@echo "  VM: $(VM_NAME) | $(VM_CPUS) CPUs | $(VM_MEM) RAM | $(VM_DISK) Disk"
	@echo "  PHP: $(PHP_VER) | Node: $(NODE_VER) | DBs: $(DATABASES)"
	@echo "$(C_CYAN)──────────────────────────────────────────────────────────$(C_RESET)"
	@echo "$(C_YELLOW)Examples:$(C_RESET)"
	@echo "  make n-shell PHP_VER=php83 DATABASES=\"postgres redis\""
	@echo "  make setup-vm PHP_VER=php84 NODE_VER=nodejs_22 DATABASES=\"mariadb\""
	@echo ""

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
	@echo "  make n-shell             # Open Nix shell"
	@echo "  make setup-vm            # Create VM"
	@echo "  make n-shell PHP_VER=    # Disable PHP"
	@echo ""

# ── Installation ──────────────────────────────────────────────────────────
install-deps: install-nix install-multipass

install-nix:
	@echo "$(C_BLUE)--> Installing Nix...$(C_RESET)"
	curl -L https://nixos.org/nix/install | sh

install-multipass:
	@echo "$(C_BLUE)--> Installing Multipass...$(C_RESET)"
ifeq ($(OS),Darwin)
	@which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install multipass
else ifeq ($(OS),Linux)
	@if [ -f /etc/debian_version ]; then \
		sudo apt-get update && sudo apt-get install -y multipass; \
	elif [ -f /etc/redhat-release ]; then \
		sudo yum install -y multipass; \
	else \
		echo "$(C_YELLOW)Unsupported Linux distro. Install multipass manually.$(C_RESET)"; \
	fi
endif

info:
	@echo "$(C_CYAN)=== SYSTEM STATUS ===$(C_RESET)"
	@echo "OS: $(OS)"
	@which nix-env > /dev/null && nix-env --version || echo "$(C_YELLOW)Nix not installed$(C_RESET)"
	@which multipass > /dev/null && multipass list || echo "$(C_YELLOW)Multipass not installed$(C_RESET)"

# ── Nix Shell ──────────────────────────────────────────────────────────────
n-shell:
	@echo "$(C_BLUE)--> Loading Nix workspace [PHP: $(PHP_VER), Node: $(NODE_VER), DBs: $(DATABASES)]...$(C_RESET)"
	nix-shell $(NIX_FILE) \
		--argstr phpVersion "$(PHP_VER)" \
		--argstr nodeVersion "$(NODE_VER)" \
		--arg enabledDatabases '$(NIX_DB_ARRAY)'

nix-clean:
	@echo "$(C_YELLOW)--> Cleaning old Nix packages...$(C_RESET)"
	nix-collect-garbage -d
	nix-store --optimise
	@echo "$(C_GREEN)--> Done$(C_RESET)"

nix-update:
	@echo "$(C_BLUE)--> Updating Nix channels...$(C_RESET)"
	nix-channel --update

# ── Multipass VM ──────────────────────────────────────────────────────────
setup-vm:
	@echo "$(C_BLUE)--> Creating VM: $(VM_NAME) [$(VM_CPUS) CPUs, $(VM_MEM) RAM, $(VM_DISK) Disk]$(C_RESET)"
	@echo "$(C_BLUE)--> PHP: $(PHP_VER) | Node: $(NODE_VER) | DBs: $(DATABASES)$(C_RESET)"
	@sed -e 's/%%php_version%%/$(PHP_VER)/g' \
	     -e 's/%%node_version%%/$(NODE_VER)/g' \
	     -e 's/%%enabled_databases%%/$(DATABASES)/g' \
	     $(CLOUD_INIT_TPL) > $(CLOUD_INIT_OUT)
	multipass launch --name $(VM_NAME) --cloud-init $(CLOUD_INIT_OUT) \
		--cpus $(VM_CPUS) --mem $(VM_MEM) --disk $(VM_DISK)
	@echo "$(C_BLUE)--> Mounting shared folder...$(C_RESET)"
	$(MAKE) vm-mount
	@echo "$(C_GREEN)--> VM ready! Use 'make vm-shell' to connect.$(C_RESET)"

vm-shell:
	multipass shell $(VM_NAME)

vm-start:
	multipass start $(VM_NAME)

vm-stop:
	multipass stop $(VM_NAME)

vm-restart:
	multipass restart $(VM_NAME)

vm-info:
	multipass info $(VM_NAME)

vm-mount:
	@echo "$(C_BLUE)--> Mounting '$(VM_LOCAL_DIR)' → '$(VM_REMOTE_DIR)'...$(C_RESET)"
	multipass mount $(VM_LOCAL_DIR) $(VM_NAME):$(VM_REMOTE_DIR)

vm-unmount:
	@echo "$(C_YELLOW)--> Unmounting...$(C_RESET)"
	multipass umount $(VM_NAME)

vm-purge:
	@echo "$(C_RED)--> Deleting VM: $(VM_NAME)...$(C_RESET)"
	-multipass stop $(VM_NAME)
	-multipass delete $(VM_NAME)
	multipass purge
	@echo "$(C_GREEN)--> Gone.$(C_RESET)"

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
