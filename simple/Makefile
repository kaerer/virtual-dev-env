# Development Environment Management File (macOS & Linux)
.PHONY: help install-deps n-shell setup-vm vm-shell vm-stop vm-purge

# Variables
VM_NAME ?= dev-box
VM_CPUS ?= 2
VM_MEM ?= 2G
VM_DISK ?= 10G
CLOUD_INIT_FILE ?= multipass-init.yaml

# Operating System Detection
UNAME_S := $(shell uname -s)

help:
	@echo "--- Development Environment Control Panel ---"
	@echo "1. Host Machine Preparation:"
	@echo "   make install-nix       : Installs Nix package manager"
	@echo "   make install-multipass : Installs Multipass (VM tool)"
	@echo "2. Nix-Shell (Lightweight Isolated Environment):"
	@echo "   make n-shell       : Opens isolated terminal with shell.nix content"
	@echo ""
	@echo "3. Multipass (Fully Isolated VM):"
	@echo "   make setup-vm      : Creates and configures Ubuntu-based VM"
	@echo "   make vm-shell      : Connects to VM via SSH/Shell"
	@echo "   make vm-stop       : Stops the VM"
	@echo "   make vm-purge      : Completely deletes and purges the VM"

install-deps: install-nix install-multipass

install-nix:
	@echo "Installing Nix..."
	curl -L https://nixos.org/nix/install | sh

install-multipass:
ifeq ($(UNAME_S),Darwin)
	@echo "macOS detected, installing Multipass (Brew)..."
	@which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install multipass
else ifeq ($(UNAME_S),Linux)
	@echo "Linux detected, installing Multipass..."
	@if [ -f /etc/debian_version ]; then \
		sudo apt-get update && sudo apt-get install -y multipass; \
	elif [ -f /etc/redhat-release ]; then \
		sudo yum install -y multipass; \
	else \
		echo "Unsupported Linux distribution. Please install the multipass package manually."; \
	fi
endif

n-shell:
	@echo "Loading Nix environment..."
	nix-shell shell.nix

setup-vm:
	@echo "Starting Multipass VM ($(VM_NAME))..."
	multipass launch --name $(VM_NAME) --cloud-init $(CLOUD_INIT_FILE) --cpus $(VM_CPUS) --mem $(VM_MEM) --disk $(VM_DISK)
	@echo "VM Ready! You can use the 'make vm-shell' command."

vm-shell:
	multipass shell $(VM_NAME)

vm-stop:
	multipass stop $(VM_NAME)

vm-purge:
	multipass delete $(VM_NAME)
	multipass purge
