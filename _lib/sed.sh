# Edit a file in place.  BSD sed, which macos ships, needs an argument for the
# backup suffix, GNU sed does not accept one.
sed_edit() {
  local script="$1"
  local file="$2"

  if [[ ! -f "$file" ]]; then
    return 0
  fi

  if is_macos; then
    sed -i '' "$script" "$file"
  else
    sed -i "$script" "$file"
  fi
}