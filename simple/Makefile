# ==============================================================================
# SIMPLE DEVELOPMENT ENVIRONMENT (Makefile)
# ==============================================================================
# Config-first development environment using Multipass and Nix Shell.
# Fixed configuration managed through manual editing.
#
# Quick Start:
#   make setup          # One-time: copy .env.example → .env, show instructions
#   make n-shell        # Open Nix shell
#   make setup-vm       # Create Multipass VM
#   make vm-shell       # SSH into VM
# ==============================================================================

# ── Load .env if exists ──────────────────────────────────────────────────
ifneq (,$(wildcard .env))
    include .env
    export
endif

# ── Variables ────────────────────────────────────────────────────────────
VM_NAME         ?= dev-box
VM_CPUS         ?= 2
VM_MEM          ?= 2G
VM_DISK         ?= 10G
CLOUD_INIT_FILE ?= .virtual-dev-env/multipass-init.yaml
NIX_FILE        ?= .virtual-dev-env/shell.nix
DEPLOYMENT_FILE ?= deployment.zip
DEPLOY_IGNORE   ?= .virtual-dev-env/.deployignore

# OS Detection
UNAME_S := $(shell uname -s)

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
	@echo "$(C_CYAN)╔════════════════════════════════════════════════════════╗$(C_RESET)"
	@echo "$(C_CYAN)║         SIMPLE DEVELOPMENT ENVIRONMENT                 ║$(C_RESET)"
	@echo "$(C_CYAN)╚════════════════════════════════════════════════════════╝$(C_RESET)"
	@echo ""
	@echo "$(C_BLUE)SETUP (run once)$(C_RESET)"
	@echo "  make setup               Create .env from .env.example"
	@echo ""
	@echo "$(C_BLUE)HOST MACHINE$(C_RESET)"
	@echo "  make install-deps        Install Nix + Multipass"
	@echo "  make install-nix         Install Nix package manager"
	@echo "  make install-multipass   Install Multipass VM tool"
	@echo ""
	@echo "$(C_BLUE)NIX SHELL$(C_RESET)"
	@echo "  make n-shell             Open isolated terminal with Nix"
	@echo ""
	@echo "$(C_BLUE)MULTIPASS VM$(C_RESET)"
	@echo "  make setup-vm            Create and configure VM"
	@echo "  make vm-shell            SSH into VM"
	@echo "  make vm-stop             Stop VM"
	@echo "  make vm-purge            Delete VM permanently"
	@echo ""
	@echo "$(C_BLUE)DEPLOYMENT$(C_RESET)"
	@echo "  make create-deployment   Package project as .zip"
	@echo ""
	@echo "$(C_BLUE)CURRENT CONFIG$(C_RESET)"
	@echo "  VM: $(VM_NAME) | $(VM_CPUS) CPUs | $(VM_MEM) RAM | $(VM_DISK) Disk"
	@echo "$(C_CYAN)────────────────────────────────────────────────────────$(C_RESET)"

# ── Setup (one-time) ──────────────────────────────────────────────────────
.PHONY: setup
setup:
	@echo "$(C_BLUE)--> Initializing configuration...$(C_RESET)"
	@if [ ! -f .env ]; then \
		cp .env.example .env && \
		echo "$(C_GREEN)  ✔ Created .env from .env.example$(C_RESET)" && \
		echo "$(C_YELLOW)  → Edit .env to customize VM resources$(C_RESET)"; \
	else \
		echo "$(C_GREEN)  ✔ .env already exists$(C_RESET)"; \
	fi
	@echo "$(C_YELLOW)  → Edit .virtual-dev-env/shell.nix to change runtime versions$(C_RESET)"
	@echo "$(C_YELLOW)  → Edit .virtual-dev-env/multipass-init.yaml to customize VM packages$(C_RESET)"
	@echo ""
	@echo "$(C_GREEN)Setup complete. Next steps:$(C_RESET)"
	@echo "  make n-shell     # Open Nix shell"
	@echo "  make setup-vm    # Create VM"
	@echo ""

# ── Installation ──────────────────────────────────────────────────────────
.PHONY: install-deps install-nix install-multipass

install-deps: install-nix install-multipass

install-nix:
	@echo "$(C_BLUE)--> Installing Nix...$(C_RESET)"
	curl -L https://nixos.org/nix/install | sh

install-multipass:
	@echo "$(C_BLUE)--> Installing Multipass...$(C_RESET)"
ifeq ($(UNAME_S),Darwin)
	@which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install multipass
else ifeq ($(UNAME_S),Linux)
	@if [ -f /etc/debian_version ]; then \
		sudo apt-get update && sudo apt-get install -y multipass; \
	elif [ -f /etc/redhat-release ]; then \
		sudo yum install -y multipass; \
	else \
		echo "$(C_YELLOW)Unsupported Linux distro. Install multipass manually.$(C_RESET)"; \
	fi
endif

# ── Nix Shell ──────────────────────────────────────────────────────────────
.PHONY: n-shell
n-shell:
	@echo "$(C_BLUE)--> Loading Nix environment from $(NIX_FILE)...$(C_RESET)"
	nix-shell $(NIX_FILE)

# ── Multipass VM ──────────────────────────────────────────────────────────
.PHONY: setup-vm vm-shell vm-stop vm-purge

setup-vm:
	@echo "$(C_BLUE)--> Starting VM: $(VM_NAME) [$(VM_CPUS) CPUs, $(VM_MEM) RAM, $(VM_DISK) Disk]$(C_RESET)"
	multipass launch --name $(VM_NAME) --cloud-init $(CLOUD_INIT_FILE) --cpus $(VM_CPUS) --mem $(VM_MEM) --disk $(VM_DISK)
	@echo "$(C_GREEN)--> VM Ready! Use 'make vm-shell' to connect.$(C_RESET)"

vm-shell:
	multipass shell $(VM_NAME)

vm-stop:
	@echo "$(C_YELLOW)--> Stopping VM: $(VM_NAME)...$(C_RESET)"
	multipass stop $(VM_NAME)

vm-purge:
	@echo "$(C_RED)--> Deleting VM: $(VM_NAME)...$(C_RESET)"
	-multipass stop $(VM_NAME)
	-multipass delete $(VM_NAME)
	multipass purge
	@echo "$(C_GREEN)--> Cleanup completed.$(C_RESET)"

# ── Deployment ────────────────────────────────────────────────────────────
.PHONY: create-deployment
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
