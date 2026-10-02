# Install man page
man_install() {
  file="$1"
  say "installing man page"
  run_sudo mkdir -p /usr/local/share/man/man1
  run_sudo cp "$file" /usr/local/share/man/man1/
  if command_exist mandb; then
    run_sudo mandb -q
  elif command_exist makewhatis; then
    run_sudo makewhatis /usr/local/man
  fi
}
