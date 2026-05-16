# Geliştirme Ortamı Yönetim Dosyası (macOS & Linux)
.PHONY: help install-deps n-shell setup-vm vm-shell vm-stop vm-purge

# İşletim Sistemi Tespiti
OS := $(shell uname -s)

help:
	@echo "--- Geliştirme Ortamı Kontrol Paneli ---"
	@echo "1. Ana Makine Hazırlığı:"
	@echo "   make install-nix       : Nix paket yöneticisini kurar"
	@echo "   make install-multipass : Multipass (VM aracı) kurar"
	@echo "2. Nix-Shell (Hafif İzole Ortam):"
	@echo "   make n-shell       : shell.nix içeriğiyle izole terminal açar"
	@echo ""
	@echo "3. Multipass (Tam İzole VM):"
	@echo "   make setup-vm      : Ubuntu tabanlı VM oluşturur ve yapılandırır"
	@echo "   make vm-shell      : VM içine SSH/Shell bağlantısı yapar"
	@echo "   make vm-stop       : VM'i durdurur"
	@echo "   make vm-purge      : VM'i tamamen siler ve temizler"

install-deps: install-nix install-multipass

install-nix:
	@echo "Nix kuruluyor..."
	curl -L https://nixos.org/nix/install | sh

install-multipass:
ifeq ($(UNAME_S),Darwin)
	@echo "macOS algılandı, Multipass kuruluyor (Brew)..."
	@which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install multipass
else ifeq ($(UNAME_S),Linux)
	@echo "Linux algılandı, Multipass kuruluyor..."
	@if [ -f /etc/debian_version ]; then \
		sudo apt-get update && sudo apt-get install -y multipass; \
	elif [ -f /etc/redhat-release ]; then \
		sudo yum install -y multipass; \
	else \
		echo "Desteklenmeyen Linux dağıtımı. Lütfen multipass paketini manuel kurun."; \
	fi
endif

n-shell:
	@echo "Nix ortamı yükleniyor..."
	nix-shell shell.nix

setup-vm:
	@echo "Multipass VM başlatılıyor (dev-box)..."
	multipass launch --name dev-box --cloud-init multipass-init.yaml --cpus 2 --mem 2G --disk 10G
	@echo "VM Hazır! 'make vm-shell' komutunu kullanabilirsiniz."

vm-shell:
	multipass shell dev-box

vm-stop:
	multipass stop dev-box

vm-purge:
	multipass delete dev-box
	multipass purge
