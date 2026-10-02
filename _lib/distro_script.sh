distro_script() {
  prefix=${1:-main}
  script="${prefix}-${DISTRO}"

  if [[ -f "$script" ]]; then
    . "$script"
  else
    unsupported "no ${script} script, this tool is not available for $OS"
  fi
}
