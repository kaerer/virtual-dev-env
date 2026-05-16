# ==============================================================================
# UNIFIED DEVELOPMENT ENVIRONMENT ORCHESTRATOR (Makefile)
# macOS (Homebrew) & Linux (Apt/Yum Multi-Distro Fallback) Uyumlu
# ==============================================================================

# ==============================================================================
# 1. YAPILANDIRMA VE DEĞİŞKENLER (CONFIG & VARIABLES)
# ==============================================================================
OS               := $(shell uname -s)

# Sanal Makine (Multipass) Konfigürasyonu
VM_NAME          := dev-box
VM_CPUS          := 2
VM_MEM           := 2G
VM_DISK          := 15G
VM_LOCAL_DIR     := .
VM_REMOTE_DIR    := /home/ubuntu/project-workspace
CLOUD_INIT       := multipass-init.yaml

# Nix Yapılandırma Dosyası
NIX_FILE         := shell.nix

# Varsayılan Çalışma Zamanı Sürümleri (Nix ve VM Tarafına Dinamik Geçirilir)
# Sürümü değiştirmek için burayı güncellemeniz yeterlidir! (Örn: php82, php83, php84)
# Devre dışı bırakmak için tamamen boş bırakabilirsiniz! (Örn: PHP_VER := )
PHP_VER          := php82
NODE_VER         := nodejs_18

# Aktif Edilecek Veritabanı Listesi (Boşluklarla ayrılmış dizi/array formatında)
# İstediğiniz servisleri ekleyip çıkarabilirsiniz (Seçenekler: redis, postgres, mariadb, sqlite)
#DATABASES        := redis postgres mariadb sqlite
DATABASES        := redis sqlite

# Paketleme Hedef Dosyası
DEPLOYMENT_FILE := deployment.zip

# --------------------

# Boşlukla ayrılmış listeyi Nix array formatına dönüştürür: [ "redis" "postgres" ... ]
NIX_DB_ARRAY     := [ $(foreach db,$(DATABASES),"$(db)") ]

# Terminal Renklendirme Kodları (Professional UX)
C_RESET          := \033[0m
C_BLUE           := \033[1;34m
C_GREEN          := \033[1;32m
C_YELLOW         := \033[1;33m
C_RED            := \033[1;31m
C_CYAN           := \033[1;36m
C_SUCCESS        := \033[1;32m

# ==============================================================================
# 2. HEDEF TANIMLAMALARI (.PHONY)
# ==============================================================================
.PHONY: help install-deps install-nix install-multipass info n-shell nix-clean nix-update setup-vm vm-shell vm-start vm-stop vm-restart vm-info vm-mount vm-unmount vm-purge create-deployment

# ==============================================================================
# 3. YARDIM VE PANEL ARAYÜZÜ
# ==============================================================================
help:
	@echo "$(C_CYAN)========================================================================$(C_RESET)"
	@echo "$(C_CYAN)                 GELİŞTİRME ORTAMI SİSTEM KONTROL PANELİ                $(C_RESET)"
	@echo "$(C_CYAN)========================================================================$(C_RESET)"
	@echo "$(C_BLUE)1. ANA MAKİNE SİSTEM YÖNETİMİ & DENETİM$(C_RESET)"
	@echo "   make install-deps     : Gerekli tüm araçları (Nix, Multipass vb.) otomatik kurar."
	@echo "   make install-nix      : Nix paket yöneticisini kurar"
	@echo "   make install-multipass: Multipass (VM aracı) kurar"
	@echo "   make info             : Sistemdeki servislerin durumunu ve IP'leri raporlar."
	@echo ""
	@echo "$(C_BLUE)2. NIX-SHELL (TEK VE BİRLEŞİK ÇALIŞMA ORTAMI)$(C_RESET)"
	@echo "   make n-shell          : Tüm dilleri içeren ana shell'i açar."
	@echo "                           * Veritabanı toggleri Makefile değişkenlerinden yönetilir."
	@echo "   make nix-clean        : Eski kütüphane sürümlerini temizler, disk alanı açar."
	@echo "   make nix-update       : Nix paket indeks kanallarını tamamen günceller."
	@echo ""
	@echo "$(C_BLUE)3. MULTIPASS (TAM İZOLE SANAL MAKİNE ALTYAPISI)$(C_RESET)"
	@echo "   make setup-vm         : Cloud-init ve dinamik PHP sürümüyle Ubuntu VM ayağa kaldırır."
	@echo "   make vm-shell         : VM içine güvenli kabuk (SSH/Shell) bağlantısı açar."
	@echo "   make vm-start         : Durdurulmuş olan sanal makineyi başlatır."
	@echo "   make vm-stop          : Sanal makineyi güvenli modda kapatır."
	@echo "   make vm-restart       : Sanal makineye hızlı yeniden başlatma uygular."
	@echo "   make vm-info          : VM'in kaynak tüketimini (CPU, RAM, Disk, IP) raporlar."
	@echo "   make vm-mount         : Yerel dizini sanal makine içine canlı olarak bağlar."
	@echo "   make vm-unmount       : Klasör senkronizasyon bağını güvenle keser."
	@echo "   make vm-purge         : Sanal makineyi ve tüm disk imajını kökten yok eder."
	@echo ""
	@echo "$(C_BLUE)4. NIX-SHELL DINAMIK KULLANIM SENARYOLARI$(C_RESET)"
	@echo "   $(C_GREEN)make n-shell$(C_RESET)"
	@echo "     Örnek 1  : make n-shell DATABASES=\"redis sqlite\""
	@echo "     Örnek 2  : make n-shell PHP_VER=php83 DATABASES=\"postgres\""
	@echo "     Örnek 3  : make n-shell PHP_VER=\"\" NODE_VER=\"\" DATABASES=\"sqlite\""
	@echo ""
	@echo "$(C_BLUE)5. DAĞITIM VE PAKETLEME (DEPLOYMENT)$(C_RESET)"
	@echo "   make create-deployment : .deployignore listesini ayıklayarak zip paketi üretir."
	@echo "$(C_CYAN)========================================================================$(C_RESET)"

# ==============================================================================
# 4. KURULUM VE SİSTEM DENETİMİ
# ==============================================================================
install-deps: install-nix install-multipass

install-nix:
	@echo "Nix kuruluyor..."
	curl -L https://nixos.org/nix/install | sh

install-multipass:
ifeq ($(OS),Darwin)
	@echo "macOS algılandı, Multipass kuruluyor (Brew)..."
	@which brew > /dev/null || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	brew install multipass
else ifeq ($(OS),Linux)
	@echo "Linux algılandı, Multipass kuruluyor..."
	@if [ -f /etc/debian_version ]; then \
		sudo apt-get update && sudo apt-get install -y multipass; \
	elif [ -f /etc/redhat-release ]; then \
		sudo yum install -y multipass; \
	else \
		echo "Desteklenmeyen Linux dağıtımı. Lütfen multipass paketini manuel kurun."; \
	fi
endif

info:
	@echo "$(C_CYAN)=== SİSTEM DURUM RAPORU ===$(C_RESET)"
	@echo "Host İşletim Sistemi: $(C_SUCCESS)$(OS)$(C_RESET)"
	@echo "--- Nix İstatistikleri ---"
	@which nix-env > /dev/null && nix-env --version || echo "$(C_YELLOW)Nix henüz kurulu veya aktif değil.$(C_RESET)"
	@echo "--- Multipass Sanal Ortam Listesi ---"
	@which multipass > /dev/null && multipass list || echo "$(C_YELLOW)Multipass kurulu değil.$(C_RESET)"

# ==============================================================================
# 5. UNIFIED NIX-SHELL YÖNETİMİ
# ==============================================================================
n-shell:
	@echo "$(C_BLUE)--> Nix tümleşik çalışma ortamı yükleniyor (Veritabanı dizisi: '$(DATABASES)')...$(C_RESET)"
	nix-shell $(NIX_FILE) \
		--argstr phpVersion "$(PHP_VER)" \
		--argstr nodeVersion "$(NODE_VER)" \
		--arg enabledDatabases '$(NIX_DB_ARRAY)'

nix-clean:
	@echo "$(C_YELLOW)--> Nix çöp toplayıcısı çalıştırılıyor (Eski paket sürümleri temizleniyor)...$(C_RESET)"
	nix-collect-garbage -d
	@echo "$(C_YELLOW)--> Nix veri deposu optimize ediliyor (Aynı dosyalar linkleniyor)...$(C_RESET)"
	nix-store --optimise
	@echo "$(C_SUCCESS)--> Temizlik tamamlandı!$(C_RESET)"

nix-update:
	@echo "$(C_BLUE)--> Nix paket kanalları güncelleniyor...$(C_RESET)"
	nix-channel --update

# ==============================================================================
# 6. MULTIPASS VM SANALLAŞTIRMA KATMANI
# ==============================================================================
setup-vm:
	@echo "$(C_BLUE)--> Geliştirme sanal makinesi ($(VM_NAME)) [Hedef PHP: $(PHP_VER)] sürümüyle oluşturuluyor...$(C_RESET)"
	multipass launch --name $(VM_NAME) --cloud-init $(CLOUD_INIT) --cpus $(VM_CPUS) --mem $(VM_MEM) --disk $(VM_DISK) --param php_version="$(PHP_VER)" --param node_version="$(NODE_VER)" --param enabled_databases="$(DATABASES)"
	@echo "$(C_BLUE)--> Ortak klasör otomatik bağlanıyor...$(C_RESET)"
	$(MAKE) vm-mount
	@echo "$(C_SUCCESS)--> İşlem Başarılı! 'make vm-shell' ile kodlamaya başlayabilirsiniz.$(C_RESET)"

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
	@echo "$(C_BLUE)--> Mevcut dizin VM içindeki '$(VM_REMOTE_DIR)' konumuna eşleniyor...$(C_RESET)"
	multipass mount $(VM_LOCAL_DIR) $(VM_NAME):$(VM_REMOTE_DIR)

vm-unmount:
	@echo "$(C_YELLOW)--> Klasör bağlantısı kesiliyor...$(C_RESET)"
	multipass umount $(VM_NAME)

vm-purge:
	@echo "$(C_RED)--> VM kapatılıyor ve disk imajı tamamen siliniyor...$(C_RESET)"
	-multipass stop $(VM_NAME)
	-multipass delete $(VM_NAME)
	multipass purge
	@echo "$(C_SUCCESS)--> VM arkasında iz bırakmadan temizlendi.$(C_RESET)"

# ==============================================================================
# 7. DAĞITIM VE PAKETLEME (DEPLOYMENT & PACKAGING)
# ==============================================================================
create-deployment:
	@echo "$(C_BLUE)--> Dağıtım paketi hazırlanıyor ($(DEPLOYMENT_FILE))...$(C_RESET)"
	@rm -f $(DEPLOYMENT_FILE)
	@if [ ! -f .deployignore ]; then \
		echo "$(C_YELLOW)⚠️  .deployignore dosyası bulunamadı! Tüm proje dosyaları sıkıştırılıyor...$(C_RESET)"; \
		zip -r $(DEPLOYMENT_FILE) . ; \
	else \
		echo "$(C_GREEN)✔️  .deployignore aktif. İstenmeyen dosyalar eleniyor...$(C_RESET)"; \
		zip -r $(DEPLOYMENT_FILE) . -x@.deployignore ; \
	fi
	@echo "$(C_SUCCESS)--> Dağıtım paketi başarıyla oluşturuldu: $(DEPLOYMENT_FILE) $(C_RESET)"