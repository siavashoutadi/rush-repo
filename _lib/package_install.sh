package_install() {
  say "installing $*"

  case "$DISTRO" in
    arch)          run_sudo pacman -S --noconfirm "$@" ;;
    debian|ubuntu) run_sudo apt-get install -y "$@" ;;
    fedora)        run_sudo dnf install -y "$@" ;;
    macos)         brew_install "$@" ;;
    *)             fail "unsupported distro:$DISTRO"
  esac
}
