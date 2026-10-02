# Stop the script when the current os is not supported by this tool
require_os() {
  local want="$1"
  local tool="${2:-$(tool_name)}"

  if [[ "$OS" != "$want" ]]; then
    fail "$tool is not supported on $OS (requires $want)"
    exit 1
  fi
}

require_linux() {
  require_os "linux" "${1:-$(tool_name)}"
}

require_macos() {
  require_os "macos" "${1:-$(tool_name)}"
}

# Stop the script with a custom reason, for the cases that are more specific
# than just "this tool does not run here"
unsupported() {
  fail "$(tool_name) is not supported on $OS - $1"
  exit 1
}