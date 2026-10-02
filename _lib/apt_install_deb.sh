# Install a .deb package from a URL using apt
apt_install_deb() {
  url="$1"
  require_linux
  tmpdir=$(temp_dir)
  pushd "$tmpdir" || fail "cannot pushd"
  run wget -O package.deb "$url"
  run_sudo apt-get -yf install ./package.deb
  popd || fail "cannot popd"
  rm -rf "$tmpdir"
}
