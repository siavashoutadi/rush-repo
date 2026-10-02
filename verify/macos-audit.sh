#!/usr/bin/env bash
# Audit the macos support of every tool in this repository, from a linux host.
#
#   ./verify/macos-audit.sh
#
# Checks
#   1. every shell file in the repo parses
#   2. every tool has a macos code path: a main-macos / undo-macos variant, an
#      is_macos branch, a require_* guard, or only _lib helpers that branch
#   3. tools that cannot run on macos stop with a clear message and exit 1
#   4. the macos code path never reaches for a linux only command
#   5. every homebrew name the macos code path uses really exists
#   6. the bash and zsh configuration of the bashrc tool is idempotent
#
# Step 4 and 5 run each tool in a sandbox: every system command is replaced by
# a stub that only records its arguments, HOME is a temporary directory, and
# downloads are stubs too.  A tool that cannot finish inside the sandbox is
# reported as "not verifiable" instead of failing.
#
# Environment
#   RUSH_AUDIT_OFFLINE=1   skip the homebrew api lookups

set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO" || exit 1

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

failures=0
warnings=0

pass() { printf '  \033[32mok\033[0m     %s\n' "$1"; }
warn() { printf '  \033[33mwarn\033[0m   %s\n' "$1"; warnings=$((warnings + 1)); }
bad()  { printf '  \033[31mFAIL\033[0m   %s\n' "$1"; failures=$((failures + 1)); }
head1() { printf '\n\033[1m%s\033[0m\n' "$1"; }

# Commands that only exist on linux
linux_commands=(apt apt-get apt-cache add-apt-repository dpkg dpkg-query dnf rpm
                systemctl update-alternatives usermod userdel groupdel xdotool
                snap flatpak pacman apk)

tools() {
  local dir
  for dir in */; do
    dir="${dir%/}"
    [[ -f "$dir/main" ]] && printf '%s\n' "$dir"
  done
}

# Commands that only exist on linux, or linux only packages
linux_only() {
  grep -qE 'apt-get|apt_install_deb|apt_install|dnf_install_rpm|systemctl|add-apt-repository|update-alternatives|xdotool|usermod|pacman|/etc/apt|/etc/systemd|\.deb|\.rpm|snap install' "$1"
}

has_guard() {
  grep -qE '(^|[^_[:alnum:]])(require_linux|require_macos|require_os|unsupported)([^_[:alnum:]]|$)' "$1"
}

has_macos_branch() {
  grep -qE 'is_macos|macos[[:space:]]*\)' "$1"
}

# macos handling of one script: variant, inline, guard or lib
macos_kind() {
  local tool="$1" file="$2"

  [[ -f "$tool/main-macos" || -f "$tool/undo-macos" ]] && { echo variant; return; }
  [[ -f "$file" ]] || { echo lib; return; }
  has_macos_branch "$file" && { echo inline; return; }
  has_guard "$file" && { echo guard; return; }
  linux_only "$file" || { echo lib; return; }
  echo unhandled
}

# A stub that records "<command> <args>" in $RUSH_AUDIT_LOG and exits 0
stub() {
  local shims="$1"
  local name="$2"

  cat > "$shims/$name" <<'EOF'
#!/usr/bin/env bash
printf '%s %s\n' "$(basename "$0")" "$*" >> "$RUSH_AUDIT_LOG"
exit 0
EOF
  chmod +x "$shims/$name"
}

# Run one tool script on macos inside the sandbox, echo its exit code
sandbox_run() {
  local tool="$1" script="$2"
  local home="$WORK/home/$tool-${script%.sh}"

  mkdir -p "$home"
  : > "$WORK/log"

  (
    cd "$tool" || exit 1
    PATH="$SHIMS:$PATH" \
    HOME="$home" \
    REPO_PATH="$REPO" \
    RUSH_OS="${RUSH_OS:-macos}" \
    RUSH_AUDIT_LOG="$WORK/log" \
    bash "./$script" > "$WORK/out-$tool-$script" 2>&1
    code=$?
    cat "$WORK/log" >> "$WORK/all-log"
    exit $code
  )
}

#############################################################################
head1 "1. shell syntax"
#############################################################################

syntax_errors=0
while read -r script; do
  if ! bash -n "$script" 2> "$WORK/err"; then
    bad "$script"
    sed 's/^/         /' "$WORK/err"
    syntax_errors=$((syntax_errors + 1))
  fi
done < <(find . -path ./.git -prune -o -path ./.agents -prune -o \( -name '*.sh' -o -name main -o -name undo -o -name 'main-*' -o -name 'undo-*' \) -type f -print | sort)

if [[ $syntax_errors -eq 0 ]]; then
  pass "every shell file parses"
fi

#############################################################################
head1 "2. macos code path per tool"
#############################################################################

declare -A kinds=()
while read -r tool; do
  kind="$(macos_kind "$tool" "$tool/main")"
  kinds["$tool"]="$kind"
  [[ "$kind" == unhandled ]] && bad "$tool has no macos code path"
done < <(tools)

counts="$(printf '%s\n' "${kinds[@]}" | sort | uniq -c | tr -s ' ' | paste -sd' ' -)"
pass "tool macos handling: ${counts:-none}"

#############################################################################
SHIMS="$WORK/shims"
mkdir -p "$SHIMS"
for cmd in "${linux_commands[@]}" sudo curl wget git tar unzip dpkg-deb man; do
  stub "$SHIMS" "$cmd"
done
for cmd in brew rush; do
  stub "$SHIMS" "$cmd"
done

#############################################################################
head1 "3. unsupported tools stop with a clear message"
#############################################################################

for tool in "${!kinds[@]}"; do
  [[ "${kinds[$tool]}" == guard ]] || continue
  [[ -f "$tool/main" ]] || continue

  sandbox_run "$tool" main
  code=$?
  output="$WORK/out-$tool-main"

  if [[ $code -eq 0 ]]; then
    bad "$tool/main exits 0 on macos even though it is not supported"
  elif grep -q "not supported on macos" "$output"; then
    pass "$tool/main stops with a clear message"
  else
    bad "$tool/main does not explain why it cannot run on macos"
    sed 's/^/         /' "$output" | head -n 10
  fi
done

#############################################################################
head1 "4. the macos code path stays off linux commands"
#############################################################################

reachable=()
not_verifiable=()
for tool in "${!kinds[@]}"; do
  [[ "${kinds[$tool]}" == guard ]] && continue

  for script in main undo; do
    [[ -f "$tool/$script" ]] || continue

    sandbox_run "$tool" "$script"
    code=$?

    while read -r line; do
      command="${line%% *}"
      case " ${linux_commands[*]} " in
        *" $command "*) bad "$tool/$script runs '$command' on macos" ;;
      esac
    done < "$WORK/log"

    # a tool that stops on purpose is not a tool that failed
    if [[ $code -ne 0 ]] && ! grep -q "not supported on macos" "$WORK/out-$tool-$script"; then
      not_verifiable+=("$tool/$script")
    fi
  done
done

if [[ ${#not_verifiable[@]} -gt 0 ]]; then
  warn "not verifiable in the sandbox (stubbed downloads): ${not_verifiable[*]}"
fi
[[ ${#not_verifiable[@]} -eq 0 ]] && pass "every macos code path completed"

#############################################################################
head1 "5. homebrew names exist"
#############################################################################

collect_names() {
  python3 - "$WORK/all-log" <<'PY'
import re, sys
names = set()
subcommands = {"install", "uninstall", "reinstall", "upgrade", "list", "info"}
for line in open(sys.argv[1]):
    parts = line.split()
    if not parts or parts[0] != "brew":
        continue
    for index, token in enumerate(parts[1:], start=1):
        if index == 1 and token in subcommands:
            continue
        if token.startswith("-") or "/" in token or re.search(r"[.;=<>]", token):
            continue
        names.add(token)
for name in sorted(names):
    print(name)
PY
}

names_file="$WORK/names"
collect_names > "$names_file"

if [[ ! -s "$names_file" ]]; then
  warn "no homebrew call was recorded"
elif [[ -n "${RUSH_AUDIT_OFFLINE:-}" ]]; then
  warn "skipped the api lookup, RUSH_AUDIT_OFFLINE is set"
else
  if ! curl -fsS --max-time 60 https://formulae.brew.sh/api/formula.json -o "$WORK/formula.json" ||
     ! curl -fsS --max-time 60 https://formulae.brew.sh/api/cask.json -o "$WORK/casks.json"; then
    warn "skipped the api lookup, formulae.brew.sh is not reachable"
  else
    python3 - "$WORK/formula.json" "$WORK/casks.json" "$names_file" > "$WORK/missing" <<'PY'
import json, sys
formulae = {f["name"] for f in json.load(open(sys.argv[1]))}
casks = {c["token"] for c in json.load(open(sys.argv[2]))}
for line in open(sys.argv[3]):
    name = line.strip()
    if name and name not in formulae and name not in casks:
        print(name)
PY

    if [[ -s "$WORK/missing" ]]; then
      while read -r name; do
        bad "homebrew has no formula or cask named '$name'"
      done < "$WORK/missing"
    else
      pass "every recorded homebrew name resolves ($(wc -l < "$names_file") names)"
    fi
  fi
fi

#############################################################################
head1 "6. shell configuration is idempotent"
#############################################################################

home="$WORK/bashrc-home"
mkdir -p "$home"
touch "$home/.zshrc"

if (cd "$REPO/bashrc" && HOME="$home" REPO_PATH="$REPO" RUSH_OS=macos bash ./main) > /dev/null 2>&1 &&
   (cd "$REPO/bashrc" && HOME="$home" REPO_PATH="$REPO" RUSH_OS=macos bash ./main) > /dev/null 2>&1 &&
   [[ -d "$home/.bashrc.d" && -d "$home/.zshrc.d" && -f "$home/.bashrc" && -f "$home/.zshrc" ]]; then
  pass "bashrc/main configures bash and zsh, and can run twice"
else
  bad "bashrc/main does not configure bash and zsh, or is not idempotent"
fi

#############################################################################
head1 "result"
#############################################################################

printf '  %d failure(s), %d warning(s)\n' "$failures" "$warnings"
[[ $failures -eq 0 ]] || exit 1