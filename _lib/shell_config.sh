# Directories that hold the per tool shell config snippets
bashrc_dir() {
  echo "$HOME/.bashrc.d"
}

zshrc_dir() {
  echo "$HOME/.zshrc.d"
}

# macos defaults to zsh, which never sources ~/.bashrc.  We also support zsh on
# linux for anyone who has set it up as their shell.
zsh_config_enabled() {
  if is_macos; then
    return 0
  fi

  [[ -f "$HOME/.zshrc" ]]
}

# install_shell_config <stem>
#
# Copies <stem>.bashrc into ~/.bashrc.d, and <stem>.zshrc into ~/.zshrc.d when
# such a file exists in the tool folder.
install_shell_config() {
  local stem="$1"

  run mkdir -p "$(bashrc_dir)"
  run cp "$stem.bashrc" "$(bashrc_dir)/"

  if [[ -f "$stem.zshrc" ]] && zsh_config_enabled; then
    run mkdir -p "$(zshrc_dir)"
    run cp "$stem.zshrc" "$(zshrc_dir)/"
  fi
}

# remove_shell_config <stem>
remove_shell_config() {
  local stem="$1"

  run rm -f "$(bashrc_dir)/$stem.bashrc"
  run rm -f "$(zshrc_dir)/$stem.zshrc"
}