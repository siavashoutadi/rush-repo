---
name: new-tool
description: Scaffold a new tool folder in the rush repo from templates (info/main/undo). Use when the user wants to add or onboard a new tool or CLI entry to this repo.
---

# Add a new tool to rush repo
1- You must ask the user for the name of the tool.
2- You must ask the user for the github repo url of the tool and investigate a bit about the tool.
3- You must create a folder with the name of the tool.
4- You must copy the templates from the templates folder to the newly created folder.
5- You must replace the placeholders in the copied files with one line description of the tool and the github repo url after two new lines.
6- You must update the main and undo with proper github repo and tool name.
7- You must make the tool work on macos, or refuse it explicitly:
   - `brew_install <formula>` and `brew_uninstall <formula>` when homebrew has the formula
   - `cask_install <token>` and `cask_uninstall <token>` for a gui application
   - a `main-macos` / `undo-macos` variant for tools that are per distro, `distro_script main` picks it up automatically
   - a darwin release asset, or `dmg_install_app <url> <App.app>` / `dmg_uninstall_app "<App>.app"` for a disk image
   - `require_linux` or `unsupported "<reason>"` when the tool cannot run on macos at all
8- Shell configuration belongs in `<tool>.bashrc` and `<tool>.zshrc`, installed with `install_shell_config <tool>` and removed with `remove_shell_config <tool>`. Never copy into `~/.bashrc.d` or `~/.zshrc.d` by hand.
9- Wrap side effects in `run`, `run_sudo`, `curl_install_script` or the package helpers, so `RUSH_DRY_RUN=1` stays usable.
10- You must run `./verify/macos-audit.sh` and fix every failure it reports for the new tool.
