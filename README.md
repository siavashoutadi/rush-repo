Rush Repo - Siavash Rush Repository
==================================================

This is my rush repo for use with the [rush package manager][rush-cli].

[rush-cli]: https://github.com/DannyBen/rush-cli

Platforms
==================================================

Every tool works on linux. Tools that also work on macos say so in their `main`
script, and the tools that cannot run there stop with a clear message instead of
failing halfway through:

    flameshot | flameshot is not supported on macos (requires linux)

`_lib/os.sh` resolves the platform to `linux` or `macos`, and
`_lib/linux_distro.sh` turns linux into `ubuntu`, `debian`, `arch` or `fedora`.
Set `RUSH_OS` to force a platform.

macos specifics
==================================================

- packages come from homebrew through `package_install`, `brew_install` and
  `cask_install`, gui applications come from `cask_install`
- gui applications shipped as a disk image use `dmg_install_app` and
  `dmg_uninstall_app`
- shell snippets live next to the tool as `<tool>.bashrc` and `<tool>.zshrc` and
  are copied by `install_shell_config`, the bashrc tool wires both `~/.bashrc.d`
  and `~/.zshrc.d`
- `os_arch` returns `amd64` or `arm64` for release assets that are published per
  architecture

Environment
==================================================

| variable        | effect                                              |
| --------------- | --------------------------------------------------- |
| `RUSH_OS`       | force the platform, for example `macos`              |
| `RUSH_ARCH`     | force the architecture, for example `arm64`          |
| `RUSH_DRY_RUN`  | print what a tool would do instead of doing it      |
| `BREW`          | path to the homebrew executable                      |

Verify
==================================================

`./verify/macos-audit.sh` runs from linux and checks the whole repo:

1. every shell file parses
2. every tool has a macos code path
3. unsupported tools stop with a clear message
4. the macos code path never reaches for a linux only command, verified by
   running every tool with stubbed system commands
5. every homebrew name the macos code path uses exists, checked against the
   homebrew api
6. the bash and zsh configuration of the bashrc tool is idempotent

Use `RUSH_AUDIT_OFFLINE=1` to skip the homebrew api lookups.
