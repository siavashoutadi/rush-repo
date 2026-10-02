package_uninstall() {
  say "uninstalling $*"

  case "$DISTRO" in
    arch)          run_sudo pacman -Rs --noconfirm "$@" || true ;;
    debian|ubuntu) run_sudo apt-get remove -y "$@" ;;
    fedora)        run_sudo dnf remove -y "$@" ;;
    macos)         brew_uninstall "$@" ;;
    *)             fail "unsupported distro:$DISTRO"
  esac
}
