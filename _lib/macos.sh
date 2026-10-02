# Install a macos .app bundle from a .dmg url into /Applications
# The app name is a hint, a single .app bundle is auto detected when the name
# does not match.
dmg_install_app() {
  local url="$1"
  local app="$2"
  local mountpoint
  local app_path

  if [[ -n "$RUSH_DRY_RUN" ]]; then
    say "DRY RUN: install $app from $url into /Applications"
    return 0
  fi

  say "installing $app"
  pushtmp

  if ! run curl -fsSL -o app.dmg "$url"; then
    popd
    return 1
  fi

  mountpoint=$(hdiutil attach -nobrowse -readonly app.dmg | awk -F '\t' '{ print $NF }' | tail -n 1)

  if [[ -z "$mountpoint" ]]; then
    fail "cannot mount $url"
    popd
    return 1
  fi

  app_path="$mountpoint/$app"

  if [[ ! -d "$app_path" ]]; then
    app_path=$(find "$mountpoint" -maxdepth 2 -name '*.app' -type d 2> /dev/null | head -n 1)
  fi

  if [[ -z "$app_path" ]]; then
    fail "no .app bundle found in the downloaded image"
    hdiutil detach "$mountpoint" -quiet
    popd
    return 1
  fi

  say "copying $(basename "$app_path") to /Applications"
  sudo rm -rf "/Applications/$(basename "$app_path")"
  sudo cp -R "$app_path" /Applications/
  hdiutil detach "$mountpoint" -quiet

  popd
  say "$(basename "$app_path") installation complete"
}

# Remove a macos .app bundle from /Applications, the name can be a glob
dmg_uninstall_app() {
  local app="$1"
  local matches
  local match

  matches=$(find /Applications -maxdepth 1 -mindepth 1 -name "$app" 2> /dev/null)

  if [[ -z "$matches" ]]; then
    say "no $app in /Applications, nothing to remove"
    return 0
  fi

  while read -r match; do
    say "removing $match"
    [[ -n "$RUSH_DRY_RUN" ]] && continue
    sudo rm -rf "$match"
  done <<< "$matches"
}