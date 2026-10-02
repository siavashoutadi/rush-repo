# Return the linux distro as a lowercase string, or "macos" when not on linux
linux_distro() {
  if is_macos; then
    echo "macos"
  elif ! is_linux; then
    echo "unknown"
  elif [ -f "/etc/os-release" ]; then
    source /etc/os-release
    dist=$(echo "$ID" | tr '[:upper:]' '[:lower:]')
    if [[ "$dist" == "zorin" ]]; then
      echo "ubuntu"
    else
      echo $dist
    fi
  elif [ -f "/etc/lsb-release" ]; then
    source /etc/lsb-release
    echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]'
  elif [ -f "/etc/debian_version" ]; then
    echo "debian"
  elif [ -f "/etc/redhat-release" ]; then
    echo "centos"
  else
    echo "unknown"
  fi
}
