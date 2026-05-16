{ pkgs ? import <nixpkgs> {}
# 1. PARAMETRIC VARIABLES FOR RUNTIME VERSIONS AND ENABLED DATABASES
, phpVersion ? "php82"          # Options: "php81", "php82", "php83", "php84", "" (or null to disable)
, nodeVersion ? "nodejs_18"     # Options: "nodejs_16", "nodejs_18", "nodejs_20", "nodejs_22", "" (or null to disable)
, enabledDatabases ? [ "redis" "sqlite" ]
}:
#[ "redis" "postgres" "mariadb" "sqlite" ]

let
  # Helper to safe check optional strings
  hasPhp  = phpVersion != null && phpVersion != "";
  hasNode = nodeVersion != null && nodeVersion != "";

  # Helper function to check if a database is in our enabled array/list
  hasDb = db: builtins.elem db enabledDatabases;
  withRedis    = hasDb "redis";
  withPostgres = hasDb "postgres";
  withMariaDB  = hasDb "mariadb";
  withSqlite   = hasDb "sqlite";

  # 2. DYNAMICALLY RESOLVE EXTENSION PACKS BASED ON THE VARIABALIZED VERSION
  phpExtensionPack = if hasPhp then pkgs."${phpVersion}Packages" else null;

  # 3. DEFINE THE PHP EXTENSIONS TO BE COMPRESSED INTO THE RUNTIME
  phpExtensions = enabled: with enabled; [
    bcmath
    intl
    zip
    opcache
    mbstring
  ] 
  ++ (if withRedis then [ redis ] else [])
  ++ (if withPostgres then [ pdo_pgsql pgsql ] else [])
  ++ (if withMariaDB then [ pdo_mysql mysqli ] else [])
  ++ (if withSqlite then [ pdo_sqlite sqlite3 ] else []);

  # 4. BUILD THE CUSTOMIZED RUNTIME EXTRACTION
  customPhp = if hasPhp then pkgs."${phpVersion}".withExtensions phpExtensions else null;

  commonTools = [
    pkgs.git
    pkgs.curl
    pkgs.htop
    pkgs.vim
    pkgs.wget
    pkgs.unzip
  ];

  languages =
    (if hasPhp then [ customPhp phpExtensionPack.composer ] else []) ++
    (if hasNode then [ pkgs."${nodeVersion}" pkgs.yarn ] else []) ++ [
    pkgs.go_1_21
    pkgs.python311
    pkgs.python311Packages.pip
    pkgs.python311Packages.virtualenv
  ];

  databaseTools = 
    (if withRedis then [ pkgs.redis ] else []) ++
    (if withPostgres then [ pkgs.postgresql ] else []) ++
    (if withMariaDB then [ pkgs.mariadb ] else []) ++
    (if withSqlite then [ pkgs.sqlite ] else []);

in
pkgs.mkShell {
  buildInputs = commonTools ++ languages ++ databaseTools;

  shellHook = ''
    echo "=========================================================================="
    echo " 🚀 BİRLEŞİK İZOLE GELİŞTİRME TERMİNALİ AKTİF"
    echo "=========================================================================="
    echo " 📌 AKTİF YAZILIM DİLLERİ VE ARAÇLAR:"

    if [ "${if hasPhp then "true" else "false"}" = "true" ]; then
    echo "  • PHP Ecosystem : ${phpVersion} (+ Selected Extensions & Composer)"
    echo "  - PHP:      $(${customPhp}/bin/php -r 'echo PHP_VERSION;')"
    if command -v composer >/dev/null 2>&1; then
        echo "    - Composer: \$(composer --version | awk '{print \$3}')"
      fi
    else
      echo "  • PHP Ecosystem : [KAPALI / YÜKLÜ DEĞİL]"
    fi

    if [ "${if hasNode then "true" else "false"}" = "true" ]; then
      echo "  • Node Engine   : ${nodeVersion}"
      echo "    - Node.js:  \$(node --version | sed 's/v//')"
    else
      echo "  • Node Engine   : [KAPALI / YÜKLÜ DEĞİL]"
    fi

    if command -v python3 >/dev/null 2>&1; then
      echo "  - Python:   \$(python3 --version | awk '{print \$2}')"
    else
      echo "  - Python:   [KAPALI / YÜKLÜ DEĞİL]"
    fi

    if command -v go >/dev/null 2>&1; then
      echo "  - Go:       \$(go version | awk '{print \$3}' | sed 's/go//')"
    else
      echo "  - Go:       [KAPALI / YÜKLÜ DEĞİL]"
    fi

    echo "  - Git:      \$(git --version | awk '{print \$3}')"
    echo "--------------------------------================================----------"
    echo " 📌 SERVİS DURUMLARI (Makefile Üzerinden Yönetilir):"
    echo "  • SQLite     : [${if withSqlite then "AKTIF" else "KAPALI"}]"

    # REDIS KONTROLÜ VE DURUM DETAYI
    if [ "${if withRedis then "true" else "false"}" = "true" ]; then
      if command -v redis-cli >/dev/null 2>&1 && redis-cli ping >/dev/null 2>&1; then
        echo "  • Redis      : [AKTIF - ÇALIŞIYOR]"
      else
        echo "  • Redis      : [AKTIF - DURDURULDU] -> Başlat: 'redis-server --port 6379 &'"
      fi
    else
      echo "  • Redis      : [KAPALI / YÜKLÜ DEĞİL]"
    fi

    echo "  • Postgres   : [${if withPostgres then "AKTIF" else "KAPALI"}] -> Başlat: 'initdb -D .db_data_test'"
    echo "  • MariaDB    : [${if withMariaDB then "AKTIF" else "KAPALI"}]"
    echo "=========================================================================="
    
    export PS1="\n\[\033[1;36m\](nix-shell:${phpVersion})\[\033[0m\] \[\033[1;32m\]\w\[\033[0m\] \$ "
  '';
}