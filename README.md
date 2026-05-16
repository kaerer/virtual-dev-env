# virtual-dev-env

Nix and Multipass based virtual development environments for macOS and Linux. This repository provides two different templates for setting up isolated development environments.

---

## 🇹🇷 Proje Hakkında (Turkish)
Bu depo, macOS ve Linux sistemlerinde izole geliştirme ortamları kurmak için iki farklı yapı sunar. **Nix** paket yöneticisi ile hafif (lightweight) terminal ortamları, **Multipass** ile tam izole Ubuntu tabanlı sanal makineler (VM) oluşturmanıza olanak tanır.

## 🇺🇸 Project Overview (English)
This repository provides two distinct structures for setting up isolated development environments on macOS and Linux. It leverages the **Nix** package manager for lightweight terminal environments and **Multipass** for fully isolated Ubuntu-based virtual machines (VM).

---

## 📂 Project Structure / Proje Yapısı

### 1. Simple Environment (`/simple`)
**🇺🇸 EN:** Dynamic environment managed through manual configuration file editing.  
**🇹🇷 TR:** Konfigürasyon dosyalarının manuel düzenlenmesiyle yönetilen dinamik yapı.
- **Dynamic via Config:** Change versions by editing `Makefile`, `shell.nix` or `multipass-init.yaml`.
- **Tools:** PHP 8.3, Node.js 18, Python 3.11, Git, Composer.
- **Use Case:** When you prefer a "set and forget" fixed configuration.

### 2. Complex Environment (`/complex`)
**🇺🇸 EN:** Advanced environment where everything is managed through the Makefile without touching other files.  
**🇹🇷 TR:** Diğer dosyalara dokunmadan her şeyin Makefile üzerinden yönetildiği gelişmiş yapı.
- **Dynamic via Overrides:** Change versions and services directly from the command line (e.g., `make n-shell PHP_VER=php83`).
- **Persistence:** Command-line overrides are **non-persistent**. To save your settings permanently, update the variables inside the `Makefile`.
- **UI:** Color-coded professional terminal interface with detailed resource reporting.

---

## 🚀 Quick Start / Hızlı Başlangıç

### Prerequisites / Önkoşullar
Ensure you have the following installed on your host machine:  
Sisteminizde aşağıdaki araçların kurulu olduğundan emin olun:
- **Multipass:** [Install Guide](https://multipass.run/install)
- **Nix:** [Install Guide](https://nixos.org/download.html)

### Usage / Kullanım

#### Simple Setup:
```bash
cd simple
# Edit Makefile or shell.nix to change versions
make n-shell          # Open Nix shell
make setup-vm         # Create Multipass VM
```

#### Complex Setup:
```bash
cd complex
# Run with defaults or override on the fly (non-persistent):
make n-shell PHP_VER=php83 DATABASES="postgres redis"
make setup-vm VM_MEM=4G PHP_VER=php83
```

---

## 🛠 Features / Özellikler

| Feature / Özellik | Simple | Complex |
| :--- | :---: | :---: |
| **English Support** | ✅ | ✅ |
| **Nix Shell / VM** | ✅ | ✅ |
| **Variable Overrides** | ❌ (Edit config) | ✅ (Command Line) |
| **Runtime Selection** | ✅ (Via Files) | ✅ (Dynamic/CLI) |
| **Database Selection** | ✅ (Manual) | ✅ (Dynamic/CLI) |
| **Persistence** | Permanent (Files) | Non-persistent (CLI) |
| **Deployment Tools** | ❌ | ✅ |
| **Color UI / Renkli Arayüz** | ✅ | ✅ |

---

## 📝 TODO / Roadmap
- [ ] **Docker Integration:** Add a `docker-compose` based environment for container enthusiasts.
- [ ] **Kubernetes/K3s:** A new folder for local K8s development setups.
- [ ] **Custom Cloud-Init Templates:** More specialized OS images (Debian, Arch).
- [ ] **Automated Testing:** CI/CD integration to validate environments on every commit.
- [ ] **GUI Dashboard:** A simple electron or web-based dashboard to manage these environments visually.
- [ ] **Moduler Structure:** Split code base into smaller, more manageable modules.

---

> [!TIP]
> Use `make help` inside each folder to see the most up-to-date commands and your current configuration defaults.  
> Her klasör içinde `make help` komutunu kullanarak en güncel komutları ve aktif yapılandırma varsayılanlarınızı görebilirsiniz.
