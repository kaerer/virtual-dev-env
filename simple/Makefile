# Development Environment Management File (macOS & Linux)
.PHONY: help install-deps install-nix install-multipass n-shell setup-vm vm-shell vm-stop vm-purge

# Variables
VM_NAME         ?= dev-box
VM_CPUS         ?= 2
VM_MEM          ?= 2G
VM_DISK         ?= 10G
CLOUD_INIT_FILE ?= .virtual-dev-env/multipass-init.yaml
NIX_FILE        ?= .virtual-dev-env/shell.nix
DEPLOYMENT_FILE ?= deployment.zip
DEPLOY_IGNORE   ?= .virtual-dev-env/.deployignore

# Operating System Detection
UNAME_S := $(shell uname -s)

# Terminal Color Codes
C_RESET          := \033[0m
C_BLUE           := \033[1;34m
C_GREEN          := \033[1;32m
C_YELLOW         := \033[1;33m
C_CYAN           := \033[1;36m

help:
	@echo "$(C_CYAN)========================================================================$(C_RESET)"
	@echo "$(C_CYAN)                 DEVELOPMENT ENVIRONMENT CONTROL PANEL                      $(C_RESET)"
	@echo "$(C_CYAN)========================================================================$(C_RESET)"
	@echo "$(C_BLUE)1. HOST MACHINE PREPARATION$(C_RESET)"
	@echo "   make install-deps     : Automatically installs all required dependencies."
	@echo "   make install-nix      : Installs the Nix package manager."
	@echo "   make install-multipass: Installs Multipass (VM tool)."
	@echo ""
	@echo "$(C_BLUE)2. NIX-SHELL (LIGHTWEIGHT ENVIRONMENT)$(C_RESET)"
	@echo "   make n-shell          : Opens isolated terminal with $(NIX_FILE)."
	@echo ""
	@echo "$(C_BLUE)3. MULTIPASS (VIRTUAL MACHINE)$(C_RESET)"
	@echo "   make setup-vm         : Creates and configures Ubuntu-based VM."
	@echo "   make vm-shell         : Connects to VM via SSH/Shell."
	@echo "   make vm-stop          : Stops the virtual machine."
	@echo "   make vm-purge         : Completely deletes and purges the VM."
	@echo ""
	@echo "$(C_BLUE)4. DEPLOYMENT$(C_RESET)"
	@echo "   make create-deployment: Generates a zip package using $(DEPLOY_IGNORE)."
	@echo ""
	@echo "$(C_BLUE)5. CURRENT CONFIGURATION (Defaults)$(C_RESET)"
	@echo "   VM Name    : $(VM_NAME)"
	@echo "   Resources  : $(VM_CPUS) CPUs, $(VM_MEM) RAM, $(VM_DISK) Disk"
	@echo "   Cloud-Init : $(CLOUD_INIT_FILE)"
	@echo "   Nix File   : $(NIX_FILE)"
	@echo "$(C_CYAN)========================================================================$(C_RESET)"

install-deps: install-nix install-multipass

install-nix:
	@echo "$(C_BLUE)--> Installing Nix...$(C_RESET)"
	curl -L https://nixos.org/nix/install | sh

install-multipass:
ifeq ($(UNAME_S),Darwin)
	@echo "$(C_BLUE)--> macOS detected, installing Multipass (Brew)...$(C_RESET)"
	@which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install multipass
else ifeq ($(UNAME_S),Linux)
	@echo "$(C_BLUE)--> Linux detected, installing Multipass...$(C_RESET)"
	@if [ -f /etc/debian_version ]; then \
		sudo apt-get update && sudo apt-get install -y multipass; \
	elif [ -f /etc/redhat-release ]; then \
		sudo yum install -y multipass; \
	else \
		echo "$(C_YELLOW)Unsupported Linux distribution. Please install multipass manually.$(C_RESET)"; \
	fi
endif

n-shell:
	@echo "$(C_BLUE)--> Loading Nix environment using $(NIX_FILE)...$(C_RESET)"
	nix-shell $(NIX_FILE)

setup-vm:
	@echo "$(C_BLUE)--> Starting Multipass VM: $(VM_NAME) [$(VM_CPUS) CPUs, $(VM_MEM) RAM, $(VM_DISK) Disk]$(C_RESET)"
	multipass launch --name $(VM_NAME) --cloud-init $(CLOUD_INIT_FILE) --cpus $(VM_CPUS) --mem $(VM_MEM) --disk $(VM_DISK)
	@echo "$(C_GREEN)--> VM Ready! Use 'make vm-shell' to connect.$(C_RESET)"

vm-shell:
	multipass shell $(VM_NAME)

vm-stop:
	@echo "$(C_YELLOW)--> Stopping VM: $(VM_NAME)...$(C_RESET)"
	multipass stop $(VM_NAME)

vm-purge:
	@echo "$(C_YELLOW)--> Deleting and purging VM: $(VM_NAME)...$(C_RESET)"
	multipass delete $(VM_NAME)
	multipass purge
	@echo "$(C_GREEN)--> Cleanup completed.$(C_RESET)"

create-deployment:
	@echo "$(C_BLUE)--> Preparing deployment package ($(DEPLOYMENT_FILE))...$(C_RESET)"
	@rm -f $(DEPLOYMENT_FILE)
	@if [ ! -f $(DEPLOY_IGNORE) ]; then \
		zip -r $(DEPLOYMENT_FILE) . ; \
	else \
		zip -r $(DEPLOYMENT_FILE) . -x@$(DEPLOY_IGNORE) ; \
	fi
	@echo "$(C_GREEN)--> Deployment package created: $(DEPLOYMENT_FILE)$(C_RESET)"

