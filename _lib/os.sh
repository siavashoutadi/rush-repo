# Detect the operating system as a lowercase string
#
# RUSH_OS and RUSH_ARCH exist so that the macos code paths can be exercised
# from a linux machine (see verify/macos-audit.sh)
os() {
  case "${RUSH_OS:-$(uname -s)}" in
    [Ll]inux|LINUX)            echo "linux" ;;
    [Dd]arwin|[Mm]ac|macos)     echo "macos" ;;
    *)                          echo "unknown" ;;
  esac
}

# Detect the cpu architecture, using the naming style used by most upstream
# releases (amd64 / arm64)
os_arch() {
  case "${RUSH_ARCH:-$(uname -m)}" in
    arm64|aarch64) echo "arm64" ;;
    x86_64|amd64)  echo "amd64" ;;
    *)             echo "${RUSH_ARCH:-$(uname -m)}" ;;
  esac
}

is_linux() {
  [[ "$OS" == "linux" ]]
}

is_macos() {
  [[ "$OS" == "macos" ]]
}

# The name of the tool folder we are currently running in
tool_name() {
  basename "$PWD"
}