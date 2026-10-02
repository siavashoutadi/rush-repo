# Run a command, or only print it when RUSH_DRY_RUN is set
run() {
  if [[ -n "$RUSH_DRY_RUN" ]]; then
    say "DRY RUN: $*"
    return 0
  fi

  "$@"
}

run_sudo() {
  if [[ -n "$RUSH_DRY_RUN" ]]; then
    say "DRY RUN: sudo $*"
    return 0
  fi

  sudo "$@"
}

# Download and execute an install script
curl_install_script() {
  local url="$1"
  shift

  if [[ -n "$RUSH_DRY_RUN" ]]; then
    say "DRY RUN: curl -fsSL $url | bash $*"
    return 0
  fi

  curl -fsSL "$url" | bash "$@"
}

# Verify that an installed binary answers its version flag
verify_installed() {
  if [[ -n "$RUSH_DRY_RUN" ]]; then
    return 0
  fi

  "$1" "$2"
}