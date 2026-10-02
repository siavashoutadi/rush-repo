# Resolve the brew executable.  Apple silicon installs homebrew in
# /opt/homebrew, which is not on the path of a default macos shell.
brew_cmd() {
  if [[ -n "$BREW" ]]; then
    echo "$BREW"
  elif command -v brew > /dev/null 2>&1; then
    command -v brew
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    echo "/opt/homebrew/bin/brew"
  elif [[ -x /usr/local/bin/brew ]]; then
    echo "/usr/local/bin/brew"
  else
    echo ""
  fi
}

brew_available() {
  [[ -n "$(brew_cmd)" ]]
}

ensure_homebrew() {
  if brew_available; then
    return 0
  fi

  say "homebrew not found, installing it first"
  curl_install_script "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

  if ! brew_available; then
    fail "homebrew installation failed"
    exit 1
  fi

  say "homebrew installed"
}

brew_install() {
  ensure_homebrew
  run "$(brew_cmd)" install "$@" || true
}

brew_uninstall() {
  if ! brew_available; then
    fail "homebrew not found, cannot uninstall $*"
    return 1
  fi

  run "$(brew_cmd)" uninstall "$@" || true
}

# Gui applications, installed as homebrew casks
cask_install() {
  ensure_homebrew
  run "$(brew_cmd)" install --cask "$@" || true
}

cask_uninstall() {
  if ! brew_available; then
    fail "homebrew not found, cannot uninstall $*"
    return 1
  fi

  run "$(brew_cmd)" uninstall --cask "$@" || true
}