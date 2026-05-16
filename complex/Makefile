# ==============================================================================
# UNIFIED DEVELOPMENT ENVIRONMENT ORCHESTRATOR (Makefile)
# macOS (Homebrew) & Linux (Apt/Yum Multi-Distro Fallback) Compatible
# ==============================================================================

# ==============================================================================
# 1. CONFIGURATION & VARIABLES
# ==============================================================================
OS               := $(shell uname -s)

# Virtual Machine (Multipass) Configuration
VM_NAME          ?= dev-box
VM_CPUS          ?= 2
VM_MEM           ?= 2G
VM_DISK          ?= 15G
VM_LOCAL_DIR     ?= .
VM_REMOTE_DIR    ?= /home/ubuntu/project-workspace
CLOUD_INIT       ?= multipass-init.yaml

# Nix Configuration File
NIX_FILE         ?= shell.nix

# Default Runtime Versions (Passed Dynamically to Nix and VM)
# Update here to change the version! (e.g., php82, php83, php84)
# Leave completely empty to disable! (e.g., PHP_VER := )
PHP_VER          ?= php82
NODE_VER         ?= nodejs_18

# Active Database List (Space-separated array format)
# Add or remove services as needed (Options: redis, postgres, mariadb, sqlite)
#DATABASES        ?= redis postgres mariadb sqlite
DATABASES        ?= redis sqlite

# Packaging Target File
DEPLOYMENT_FILE  ?= deployment.zip

# --------------------

# Converts space-separated list to Nix array format: [ "redis" "postgres" ... ]
NIX_DB_ARRAY     := [ $(foreach db,$(DATABASES),"$(db)") ]

# Terminal Color Codes (Professional UX)
C_RESET          := \033[0m
C_BLUE           := \033[1;34m
C_GREEN          := \033[1;32m
C_YELLOW         := \033[1;33m
C_RED            := \033[1;31m
C_CYAN           := \033[1;36m
C_SUCCESS        := \033[1;32m

# ==============================================================================
# 2. TARGET DEFINITIONS (.PHONY)
# ==============================================================================
.PHONY: help install-deps install-nix install-multipass info n-shell nix-clean nix-update setup-vm vm-shell vm-start vm-stop vm-restart vm-info vm-mount vm-unmount vm-purge create-deployment

# ==============================================================================
# 3. HELP AND PANEL INTERFACE
# ==============================================================================
help:
	@echo "$(C_CYAN)========================================================================$(C_RESET)"
	@echo "$(C_CYAN)                 DEVELOPMENT ENVIRONMENT SYSTEM CONTROL PANEL               $(C_RESET)"
	@echo "$(C_CYAN)========================================================================$(C_RESET)"
	@echo "$(C_BLUE)1. HOST MACHINE SYSTEM MANAGEMENT$(C_RESET)"
	@echo "   make install-deps     : Automatically installs all required tools."
	@echo "   make install-nix      : Installs the Nix package manager."
	@echo "   make install-multipass: Installs Multipass (VM tool)."
	@echo "   make info             : Reports status of system services and IPs."
	@echo ""
	@echo "$(C_BLUE)2. NIX-SHELL (LOCAL WORKSPACE)$(C_RESET)"
	@echo "   make n-shell          : Opens unified shell with PHP, Node, etc."
	@echo "   make nix-clean        : Frees disk space by removing old Nix versions."
	@echo "   make nix-update       : Updates Nix package channels."
	@echo ""
	@echo "$(C_BLUE)3. MULTIPASS (VIRTUAL MACHINE)$(C_RESET)"
	@echo "   make setup-vm         : Deploys VM with dynamic runtimes and DBs."
	@echo "   make vm-shell         : Opens secure shell (SSH) into the VM."
	@echo "   make vm-start/stop    : Starts or safely stops the virtual machine."
	@echo "   make vm-restart       : Performs a fast restart of the VM."
	@echo "   make vm-info          : Reports VM resource usage and IP."
	@echo "   make vm-mount/unmount : Manages folder sync between Host and VM."
	@echo "   make vm-purge         : Permanently deletes the VM and its data."
	@echo ""
	@echo "$(C_BLUE)4. DEPLOYMENT & UTILS$(C_RESET)"
	@echo "   make create-deployment: Generates a zip package using .deployignore."
	@echo ""
	@echo "$(C_BLUE)5. CURRENT CONFIGURATION (Defaults)$(C_RESET)"
	@echo "   VM Name    : $(VM_NAME)"
	@echo "   Resources  : $(VM_CPUS) CPUs, $(VM_MEM) RAM, $(VM_DISK) Disk"
	@echo "   PHP Ver    : $(PHP_VER) | Node Ver: $(NODE_VER)"
	@echo "   Databases  : $(DATABASES)"
	@echo "$(C_CYAN)========================================================================$(C_RESET)"

# ==============================================================================
# 4. INSTALLATION AND SYSTEM AUDIT
# ==============================================================================
install-deps: install-nix install-multipass

install-nix:
	@echo "Installing Nix..."
	curl -L https://nixos.org/nix/install | sh

install-multipass:
ifeq ($(OS),Darwin)
	@echo "macOS detected, installing Multipass (Brew)..."
	@which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install multipass
else ifeq ($(OS),Linux)
	@echo "Linux detected, installing Multipass..."
	@if [ -f /etc/debian_version ]; then \
		sudo apt-get update && sudo apt-get install -y multipass; \
	elif [ -f /etc/redhat-release ]; then \
		sudo yum install -y multipass; \
	else \
		echo "Unsupported Linux distribution. Please install the multipass package manually."; \
	fi
endif

info:
	@echo "$(C_CYAN)=== SYSTEM STATUS REPORT ===$(C_RESET)"
	@echo "Host Operating System: $(C_SUCCESS)$(OS)$(C_RESET)"
	@echo "--- Nix Statistics ---"
	@which nix-env > /dev/null && nix-env --version || echo "$(C_YELLOW)Nix is not installed or active yet.$(C_RESET)"
	@echo "--- Multipass Virtual Environment List ---"
	@which multipass > /dev/null && multipass list || echo "$(C_YELLOW)Multipass is not installed.$(C_RESET)"

# ==============================================================================
# 5. UNIFIED NIX-SHELL MANAGEMENT
# ==============================================================================
n-shell:
	@echo "$(C_BLUE)--> Loading unified Nix workspace (Database array: '$(DATABASES)')...$(C_RESET)"
	nix-shell $(NIX_FILE) \
		--argstr phpVersion "$(PHP_VER)" \
		--argstr nodeVersion "$(NODE_VER)" \
		--arg enabledDatabases '$(NIX_DB_ARRAY)'

nix-clean:
	@echo "$(C_YELLOW)--> Running Nix garbage collector (Cleaning old package versions)...$(C_RESET)"
	nix-collect-garbage -d
	@echo "$(C_YELLOW)--> Optimizing Nix store (Hard-linking identical files)...$(C_RESET)"
	nix-store --optimise
	@echo "$(C_SUCCESS)--> Cleanup completed!$(C_RESET)"

nix-update:
	@echo "$(C_BLUE)--> Updating Nix package channels...$(C_RESET)"
	nix-channel --update

# ==============================================================================
# 6. MULTIPASS VM VIRTUALIZATION LAYER
# ==============================================================================
setup-vm:
	@echo "$(C_BLUE)--> Creating VM: $(VM_NAME) [$(VM_CPUS) CPUs, $(VM_MEM) RAM, $(VM_DISK) Disk]$(C_RESET)"
	@echo "$(C_BLUE)--> Runtimes: PHP: $(PHP_VER), Node: $(NODE_VER)$(C_RESET)"
	@echo "$(C_BLUE)--> Databases: $(DATABASES)$(C_RESET)"
	multipass launch --name $(VM_NAME) --cloud-init $(CLOUD_INIT) --cpus $(VM_CPUS) --mem $(VM_MEM) --disk $(VM_DISK) --param php_version="$(PHP_VER)" --param node_version="$(NODE_VER)" --param enabled_databases="$(DATABASES)"
	@echo "$(C_BLUE)--> Automatically mounting shared folder...$(C_RESET)"
	$(MAKE) vm-mount
	@echo "$(C_SUCCESS)--> Setup Successful! Start coding with 'make vm-shell'.$(C_RESET)"

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
	@echo "$(C_BLUE)--> Mapping '$(VM_LOCAL_DIR)' to VM's '$(VM_REMOTE_DIR)'...$(C_RESET)"
	multipass mount $(VM_LOCAL_DIR) $(VM_NAME):$(VM_REMOTE_DIR)

vm-unmount:
	@echo "$(C_YELLOW)--> Disconnecting folder mount from $(VM_NAME)...$(C_RESET)"
	multipass umount $(VM_NAME)

vm-purge:
	@echo "$(C_RED)--> Shutting down VM and permanently deleting disk image...$(C_RESET)"
	-multipass stop $(VM_NAME)
	-multipass delete $(VM_NAME)
	multipass purge
	@echo "$(C_SUCCESS)--> VM cleared without a trace.$(C_RESET)"

# ==============================================================================
# 7. DEPLOYMENT & PACKAGING
# ==============================================================================
create-deployment:
	@echo "$(C_BLUE)--> Preparing deployment package ($(DEPLOYMENT_FILE))...$(C_RESET)"
	@rm -f $(DEPLOYMENT_FILE)
	@if [ ! -f .deployignore ]; then \
		echo "$(C_YELLOW)⚠️  .deployignore file not found! Compressing all project files...$(C_RESET)"; \
		zip -r $(DEPLOYMENT_FILE) . ; \
	else \
		echo "$(C_GREEN)✔️  .deployignore is active. Filtering out unwanted files...$(C_RESET)"; \
		zip -r $(DEPLOYMENT_FILE) . -x@.deployignore ; \
	fi
	@echo "$(C_SUCCESS)--> Deployment package successfully created: $(DEPLOYMENT_FILE) $(C_RESET)"