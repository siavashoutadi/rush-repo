# Install an .rpm package from a URL using dnf
dnf_install_rpm() {
  url="$1"
  require_linux
  tmpdir=$(temp_dir)
  pushd "$tmpdir" || fail "cannot pushd"
  run wget -O package.rpm "$url"
  run_sudo dnf -y install ./package.rpm
  popd || fail "cannot popd"
  rm -rf "$tmpdir"
}