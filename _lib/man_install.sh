# Install man page
man_install() {
  file="$1"
  say "installing man page"
  sudo mkdir -p /usr/local/share/man/man1
  sudo cp "$file" /usr/local/share/man/man1/
  if command_exist mandb; then
    sudo mandb -q
  elif command_exist makewhatis; then
    sudo makewhatis /usr/local/man
  fi
}
