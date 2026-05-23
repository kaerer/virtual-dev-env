# 🚀 Complex Development Environment (Orchestrator-First)

Dynamic, parameterized development environment using **Multipass** and **Nix Shell**. Override PHP/Node versions and databases on-the-fly via CLI or `.env`. Perfect for teams that need flexible, per-project environment configurations.

---

## 📋 Prerequisites

- **Multipass** — `make install-multipass` or [multipass.run](https://multipass.run)
- **Nix** — `make install-nix` or [nixos.org](https://nixos.org/download)

---

## 🚀 Quick Start

```bash
# 1. Copy into your project
cp -r path/to/complex/ your-project/
cd your-project/complex

# 2. One-time setup
make setup
# → Edit .env to customize versions and databases

# 3a. Nix Shell (local, lightweight)
make n-shell

# 3b. OR Multipass VM (full isolation)
make setup-vm
make vm-shell
```

---

## ⚙️ Configuration

### Via `.env` (recommended)

Run `make setup` — creates `.env` from `.env.example`. Edit once:

```bash
# .env
PHP_VER=php83
NODE_VER=nodejs_20
DATABASES=redis postgres
VM_CPUS=4
VM_MEM=4G
```

After editing, run `make n-shell` or `make setup-vm` — variables loaded automatically.

### Via CLI (override without editing)

```bash
make n-shell PHP_VER=php84 DATABASES="postgres redis"
make setup-vm PHP_VER=php83 NODE_VER=nodejs_22
```

**Disable a runtime** by setting it empty:

```bash
make n-shell PHP_VER= NODE_VER=nodejs_20    # No PHP, Node only
make setup-vm PHP_VER=php83 NODE_VER=           # PHP only, no Node
```

### Configuration reference

| Variable | Default | Options | Description |
|----------|---------|---------|-------------|
| `VM_NAME` | `dev-box` | any string | Virtual machine name |
| `VM_CPUS` | `2` | 1–8 | CPU cores |
| `VM_MEM` | `2G` | e.g., `4G`, `8G` | RAM |
| `VM_DISK` | `15G` | e.g., `20G`, `50G` | Disk space |
| `PHP_VER` | `php82` | `php81`–`php84` (empty to disable) | PHP version |
| `NODE_VER` | `nodejs_18` | `nodejs_16`–`nodejs_22` (empty to disable) | Node.js version |
| `DATABASES` | `redis sqlite` | Space-separated: `redis` `postgres` `mariadb` `sqlite` | Active databases |

---

## 📚 Commands

```bash
make help                # Show this panel

# Setup
make setup               # Create .env from .env.example

# System
make install-deps        # Install Nix + Multipass
make info                # System status report

# Nix Shell
make n-shell             # Open Nix environment
make nix-clean           # Clean old packages
make nix-update          # Update channels

# Multipass VM
make setup-vm            # Create and configure VM
make vm-shell            # SSH into VM
make vm-start/stop       # Start / Stop VM
make vm-restart          # Restart VM
make vm-info             # VM resource usage and IP
make vm-mount/unmount    # Mount / unmount host folder
make vm-purge            # Delete VM permanently

# Deployment
make create-deployment   # Package as .zip
```

---

## 🏗️ How It Works

1. **`make n-shell`** passes `PHP_VER`, `NODE_VER`, and `DATABASES` as arguments to `shell.nix`
2. **`shell.nix`** dynamically resolves PHP/Node packages and database tools
3. **`make setup-vm`** processes `multipass-init.yaml.tpl` with `sed`, substituting template variables, then launches the VM

### File Structure

```
your-project/
├── ...
└── complex/                          # Copy this folder
    ├── Makefile
    ├── README.md
    ├── .env.example
    ├── .env                          # Your config (created by make setup)
    └── .virtual-dev-env/
        ├── shell.nix                 # Parametric Nix environment
        ├── multipass-init.yaml.tpl   # Cloud-init template
        └── .deployignore
```

---

## 💡 Example Workflows

```bash
# PHP 8.3 + PostgreSQL + Redis (Nix shell)
make setup
# → Edit .env: PHP_VER=php83 DATABASES="postgres redis"
make n-shell

# PHP 8.4 + MariaDB (VM)
make setup-vm PHP_VER=php84 DATABASES="mariadb"
make vm-shell
```

---

## 🔧 Troubleshooting

**`nix-shell` fails with "attribute 'go' missing"**
→ Update your Nix channels: `make nix-update`

**Cloud-init template not rendered**
→ Always use `make setup-vm`, not `multipass launch` directly.

**"multipass: command not found"**
→ Run `make install-multipass` first.

---

> [!TIP]
> Run `make help` to see current defaults and available commands.
> Set preferences once in `.env`, then just use `make n-shell` or `make setup-vm`.
