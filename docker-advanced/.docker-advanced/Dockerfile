# ==============================================================================
# WORKSPACE DEVELOPMENT CONTAINER
# ==============================================================================
# Single container with all runtimes for polyglot development.
# Build args allow disabling runtimes you don't need.
#
# Usage:
#   docker build -t workspace .                                              # all defaults
#   docker build --build-arg GO_VERSION="" -t workspace .                     # no Go
#   docker build --build-arg PHP_VERSION=8.4 --build-arg NODE_VERSION="" .    # PHP 8.4 only
# ==============================================================================

FROM debian:bookworm-slim

LABEL org.opencontainers.image.title="Workspace Dev Container"
LABEL org.opencontainers.image.description="Go + PHP + Node + Python development environment"
LABEL org.opencontainers.image.source="https://github.com/your-org/virtual-dev-env"

# ── Prevent interactive prompts ──────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# ── Build Arguments (set empty to disable) ───────────────────────────────
ARG GO_VERSION="1.24"
ARG PHP_VERSION="8.3"
ARG NODE_VERSION="20"
ARG WORKSPACE_USER="developer"
ARG WORKSPACE_UID="1000"

# ── 1. System Dependencies ───────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget gnupg lsb-release \
    git unzip zip xz-utils \
    vim nano htop \
    build-essential \
    openssh-client \
    sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# ── 2. PHP (Optional) ────────────────────────────────────────────────────
RUN if [ -n "$PHP_VERSION" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
            apt-transport-https && \
        curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg \
            https://packages.sury.org/php/apt.gpg && \
        echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] \
            https://packages.sury.org/php/ $(lsb_release -sc) main" \
            > /etc/apt/sources.list.d/php.list && \
        apt-get update && apt-get install -y --no-install-recommends \
            php${PHP_VERSION}-cli \
            php${PHP_VERSION}-common \
            php${PHP_VERSION}-mbstring \
            php${PHP_VERSION}-xml \
            php${PHP_VERSION}-curl \
            php${PHP_VERSION}-zip \
            php${PHP_VERSION}-bcmath \
            php${PHP_VERSION}-intl \
            php${PHP_VERSION}-mysql \
            php${PHP_VERSION}-pgsql \
            php${PHP_VERSION}-sqlite3 \
            php${PHP_VERSION}-redis \
            php${PHP_VERSION}-xdebug \
        && curl -sS https://getcomposer.org/installer \
            | php -- --install-dir=/usr/local/bin --filename=composer \
        && rm -rf /var/lib/apt/lists/*; \
    else \
        echo "--> PHP installation skipped."; \
    fi

# ── 3. Node.js (Optional) ────────────────────────────────────────────────
RUN if [ -n "$NODE_VERSION" ]; then \
        curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
        apt-get install -y --no-install-recommends nodejs && \
        npm install -g yarn pnpm && \
        rm -rf /var/lib/apt/lists/*; \
    else \
        echo "--> Node.js installation skipped."; \
    fi

# ── 4. Go (Optional) ─────────────────────────────────────────────────────
RUN if [ -n "$GO_VERSION" ]; then \
        GO_ARCH="amd64"; \
        [ "$(uname -m)" = "aarch64" ] && GO_ARCH="arm64"; \
        curl -OL https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz && \
        tar -C /usr/local -xzf go${GO_VERSION}.linux-${GO_ARCH}.tar.gz && \
        rm go${GO_VERSION}.linux-${GO_ARCH}.tar.gz; \
    fi
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/workspace/.go

# ── 5. Tools & Utilities ─────────────────────────────────────────────────
# Air (Go hot-reload)
RUN if command -v go >/dev/null 2>&1; then \
        go install github.com/air-verse/air@latest; \
    fi

# ── 6. User Setup ────────────────────────────────────────────────────────
RUN useradd -m -s /bin/bash ${WORKSPACE_USER} && \
    mkdir -p /workspace && \
    chown -R ${WORKSPACE_USER}:${WORKSPACE_USER} /workspace

WORKDIR /workspace
USER ${WORKSPACE_USER}

# ── 7. Shell Enhancements ────────────────────────────────────────────────
RUN echo 'export PS1="\[\033[1;35m\](workspace)\[\033[0m\] \[\033[1;34m\]\w\[\033[0m\] \$ "' >> ~/.bashrc && \
    echo 'alias ll="ls -la"' >> ~/.bashrc && \
    echo 'alias gs="git status"' >> ~/.bashrc && \
    echo 'alias gp="git pull"' >> ~/.bashrc && \
    echo 'alias gc="git commit"' >> ~/.bashrc

# ── Healthcheck ──────────────────────────────────────────────────────────
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD php -v >/dev/null 2>&1 || node -v >/dev/null 2>&1 || go version >/dev/null 2>&1 || true

CMD ["sleep", "infinity"]
