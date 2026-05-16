# ==============================================================================
# UNIFIED DEVELOPMENT ENVIRONMENT DOCKERFILE
# ==============================================================================
# Usage Examples:
# 1. Default (PHP 8.2 + Node 18):
#    docker build -t my-dev-env .
#
# 2. Only PHP (No Node):
#    docker build --build-arg PHP_VERSION=8.3 --build-arg NODE_VERSION="" -t my-php-env .
#
# 3. Only Node (No PHP):
#    docker build --build-arg PHP_VERSION="" --build-arg NODE_VERSION=20 -t my-node-env .
#
# 4. Custom Versions:
#    docker build --build-arg PHP_VERSION=8.1 --build-arg NODE_VERSION=16 -t my-custom-env .
# ==============================================================================

FROM debian:bookworm-slim

# Set working directory
WORKDIR /app

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# 1. INSTALL CORE TOOLS (Always Installed)
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    git \
    unzip \
    zip \
    lsb-release \
    sqlite3 \
    vim \
    htop \
    && rm -rf /var/lib/apt/lists/*

# Arguments passed from Compose/Makefile
ARG PHP_VERSION=""
ARG NODE_VERSION=""

# 2. OPTIONAL PHP INSTALLATION
# Includes extensions for MySQL, PostgreSQL, SQLite, and Redis
RUN if [ -n "$PHP_VERSION" ]; then \
        echo "--> Installing PHP: $PHP_VERSION" && \
        apt-get update && apt-get install -y apt-transport-https && \
        curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg && \
        echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
        apt-get update && apt-get install -y \
        php${PHP_VERSION}-cli \
        php${PHP_VERSION}-common \
        php${PHP_VERSION}-mysql \
        php${PHP_VERSION}-pgsql \
        php${PHP_VERSION}-sqlite3 \
        php${PHP_VERSION}-redis \
        php${PHP_VERSION}-xml \
        php${PHP_VERSION}-mbstring \
        php${PHP_VERSION}-curl \
        php${PHP_VERSION}-zip \
        && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    else \
        echo "--> PHP installation skipped."; \
    fi

# 3. OPTIONAL NODEJS INSTALLATION
# Includes npm and yarn
RUN if [ -n "$NODE_VERSION" ]; then \
        echo "--> Installing Node.js: $NODE_VERSION" && \
        curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash - && \
        apt-get install -y nodejs && \
        npm install -g yarn; \
    else \
        echo "--> Node.js installation skipped."; \
    fi

# 4. PERMISSIONS & USER MANAGEMENT
RUN useradd -m -s /bin/bash developer && \
    chown -R developer:developer /app

USER developer

# Keep container running
CMD ["tail", "-f", "/dev/null"]
