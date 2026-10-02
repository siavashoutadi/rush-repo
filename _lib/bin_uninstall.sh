bin_uninstall() {
  package="$1"
  say "uninstalling $package"
  run_sudo rm -f "/usr/local/bin/$package"
}
