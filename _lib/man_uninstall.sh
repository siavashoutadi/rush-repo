# Uninstall man page
man_uninstall() {
  file="$1"
  say "uninstalling man page"
  run_sudo rm -f "/usr/local/share/man/man1/$file"
  if command_exist mandb; then
    run_sudo mandb -q
  elif command_exist makewhatis; then
    run_sudo makewhatis /usr/local/man
  fi
}
