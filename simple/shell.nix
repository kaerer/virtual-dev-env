{ pkgs ? import <nixpkgs> {} }:

let
  # 1. Define your PHP version here (e.g., php81, php82, php83)
  phpPackage = pkgs.php83;

  # 2. Define the extensions you need
  phpWithExtensions = phpPackage.withExtensions ({ all, enabled }: with all; [
    bcmath
    curl
    dom
    mbstring
    openssl
    pdo_mysql
    redis
    zip
  ]);
in

pkgs.mkShell {
  buildInputs = [
    pkgs.git
    pkgs.htop
    pkgs.python311
    pkgs.nodejs-18_x
    pkgs.curl
    pkgs.vim

    # Add the configured PHP package and Composer
    phpWithExtensions
    pkgs.phpPackages.composer
  ];

shellHook = ''
    echo "--- NIX-SHELL ORTAMI AKTIF ---"
    echo "Yüklü Paketler:"
    echo "  - PHP:      $(${phpWithExtensions}/bin/php -r 'echo PHP_VERSION;')"
    echo "  - Composer: $(composer --version | awk '{print $3}')"
    echo "  - Node.js:  $(node --version | sed 's/v//')"
    echo "  - Python:   $(python3 --version | awk '{print $2}')"
    echo "  - Git:      $(git --version | awk '{print $3}')"

    export PS1="\n\[\033[1;32m\](nix-env)\[\033[0m\] \[\033[1;34m\]\w\[\033[0m\] > "
  '';
}