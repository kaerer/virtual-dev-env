# 🏗️ Simple Development Environment (Config-First)

Straightforward, config-first development environment using **Multipass** and **Nix Shell**. Fixed configuration managed through editing. Best for developers who want a stable, predictable environment with minimal moving parts.

---

## 📋 Prerequisites

- **Multipass** — `make install-multipass` or [multipass.run](https://multipass.run)
- **Nix** — `make install-nix` or [nixos.org](https://nixos.org/download)

---

## 🚀 Quick Start

```bash
# 1. Copy into your project
cp -r path/to/simple/ your-project/
cd your-project/simple

# 2. One-time setup
make setup

# 3a. Nix Shell (local, lightweight)
make n-shell

# 3b. OR Multipass VM (full isolation)
make setup-vm
make vm-shell

# When done
make vm-stop    # Stop VM
```

---

## ⚙️ Configuration

### Via `.env` (VM resources)

Run `make setup` — creates `.env` from `.env.example`. Edit once:

```bash
VM_NAME=dev-box
VM_CPUS=2
VM_MEM=2G
VM_DISK=10G
```

### Via shell.nix (runtime versions)

Edit `.virtual-dev-env/shell.nix` directly:

```nix
phpPackage = pkgs.php83;           # Change to php82, php84, etc.
nodejsPackage = pkgs.nodejs-18_x;  # Change to nodejs-20_x, nodejs-22_x
pythonPackage = pkgs.python311;    # Change to python312, etc.
```

### Via multipass-init.yaml (VM packages)

Edit `.virtual-dev-env/multipass-init.yaml` — add/remove system packages.

---

## 📚 Commands

```bash
make help                # Show this panel

# Setup
make setup               # Create .env from .env.example

# Host Machine
make install-deps        # Install Nix + Multipass
make install-nix         # Install Nix only
make install-multipass   # Install Multipass only

# Nix Shell
make n-shell             # Open isolated Nix environment

# Multipass VM
make setup-vm            # Create and configure VM
make vm-shell            # SSH into VM
make vm-stop             # Stop VM
make vm-purge            # Delete VM permanently

# Deployment
make create-deployment   # Package project as .zip
```

---

## 🏗️ File Structure

```
your-project/
├── ...
└── simple/                          # Copy this folder
    ├── Makefile
    ├── README.md
    ├── .env.example
    ├── .env                         # Your config (created by make setup)
    └── .virtual-dev-env/
        ├── shell.nix                # Nix environment
        └── multipass-init.yaml      # VM cloud-init
```

---

## 💡 Example Workflow

```bash
# First time
make setup
# → Edit .env if you want different VM resources

# Development session
make n-shell   # or: make setup-vm && make vm-shell

# Inside the environment
php -v
node -v
python3 --version
git --version

# Exit when done
exit            # Exit Nix shell / VM shell
make vm-stop    # If using VM
```

---

## 🔧 Troubleshooting

**Need a different PHP extension?**
→ Edit `shell.nix`, add to the `phpWithExtensions` list.

**Want more VM tools?**
→ Edit `multipass-init.yaml`, add to the `packages` list.

**VM already exists error**
→ Run `make vm-purge` first, then `make setup-vm` again.

---

> [!TIP]
> Run `make help` to see available commands and current config.
> For dynamic runtime versions, use the `complex/` template instead.
