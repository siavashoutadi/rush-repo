# Uninstall man page
man_uninstall() {
  file="$1"
  say "uninstalling man page"
  sudo rm -f "/usr/local/share/man/man1/$file"
  if command_exist mandb; then
    sudo mandb -q
  elif command_exist makewhatis; then
    sudo makewhatis /usr/local/man
  fi
}
