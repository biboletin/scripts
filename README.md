# Scripts Collection (Bash)

A collection of Bash shell helpers for your development workstation. It provides convenient directory-navigation aliases, system utilities, networking tools, and general-purpose helper functions.

If something is unclear or missing, see the TODOs noted below.


## Overview
- Stack: Bash shell scripts (no external package manager)
- Primary usage: source these scripts in your shell startup file (e.g., `~/.bashrc` or `~/.zshrc`)
- Entry points: `aliases.sh`, `functions.sh` (to be sourced, not executed)
- Features:
  - Navigation aliases
  - System and network diagnostics
  - Archive extraction helper
  - Process and port inspection tools
  - Logging and error helpers

## Requirements
- Bash (recommended 4.x+)
- A POSIX-like environment (Linux/macOS). Note: Some aliases are Linux-specific.
- For the `reload` alias to work as-is:
  - systemd available (uses `systemctl`)
  - Services installed and named: 
    - `apache2`
    - `mysql`
    - `PHP-FPM`
    - `phpsessionclean`
    - Clear opcache with `php -r 'opcache_reset();'`
  - Sudo privileges (the alias calls `sudo`)

## Installation and Setup
1. Clone or copy this repository somewhere on your machine (e.g., `~/scripts`).
2. Source the scripts from your shell profile so they load automatically for new shells:
   - Bash (Linux): add to `~/.bashrc`
     ```bash
     # Scripts Collection
     if [ -f "$HOME/scripts/aliases.sh" ]; then
       # shellcheck source=/dev/null
       . "$HOME/scripts/aliases.sh"
     fi
     if [ -f "$HOME/scripts/functions.sh" ]; then
       # shellcheck source=/dev/null
       . "$HOME/scripts/functions.sh"
     fi
     ```
   - Zsh (macOS/Linux): add similar lines to `~/.zshrc`.
3. Reload your shell configuration, for example:
   ```bash
   source ~/.bashrc
   # or for zsh
   source ~/.zshrc
   ```

## How to Use
Once sourced, the aliases are available in your terminal. 

Examples:

### Aliases

| Alias     | Command                                                              |
| --------- | -------------------------------------------------------------------- |
| `home`      | cd ~/                                                                |
| `downloads` | cd ~/Downloads/                                                      |
| `documents` | cd ~/Documents/                                                      |
| `desktop`   | cd ~/Desktop/                                                        |
| `www`       | cd /var/www/html/                                                    |
| `c`         | clear                                                                |
| `reload`    | Restart Apache, MySQL, PHP-FPM + opcache_reset()                     |
| `update`    | apt update && upgrade -y && autoremove && autoclean + journal vacuum |

### Functions
| Function           | Usage                                    | Dependencies                              |
| ------------------ | ---------------------------------------- | ----------------------------------------- |
| `ipinfo <IP/domain>` | WHOIS, GeoIP, DNS, traceroute, nmap scan | whois, geoiplookup, dig, traceroute, nmap |
| `sysinfo`            | Host, uptime, kernel, OS, RAM, disk      | uname, uptime, free, df                   |
| `psg <pattern>`      | Filter processes (case-insensitive)      | ps, awk                                   |
| `ports`              | All TCP/UDP ports + processes            | ss + sudo                                 |
| `port <number>`      | Process using specific port              | ss + sudo                                 |
| `myip`               | Public IP address                        | curl                                      |
| `httpinfo <host>`    | HTTP headers + TLS certificate           | curl, openssl                             |
| `extract <archive>`  | Extract tar.gz, zip, 7z                  | tar, unzip, 7z                            |
| `findbig [dir]`      | 20 largest files/folders                 | du                                        |
| `mkcd <dir>`         | mkdir -p && cd                           | mkdir, cd                                 |


Notes:
- The `reload` alias restarts Apache, MySQL, and the PHP session cleaner service on systemd-based systems. Adjust to match your system (service names vary by distro, e.g., `httpd`, `mariadb`, etc.).
- All scripts set strict Bash options (`set -euo pipefail`) and a safe Internal Field Separator (`IFS=$'\n\t'`). Avoid sourcing them in contexts where these options would be undesirable.

## Environment Variables
- No required custom environment variables are defined by these scripts.
- The scripts set the shell options mentioned above; they are session-scoped after sourcing.

## Scripts Reference
- aliases.sh
  - Defines convenience aliases for common directories and tasks (see list above).
- functions.sh
  - Placeholder for future shell functions. Currently sets strict shell options but defines no functions.

## Project Structure
- README.md — this file
- aliases.sh — alias definitions
- functions.sh — reserved for future function helpers

## Running Tests
- There are currently no automated tests for these Bash scripts.
- TODO: Add minimal smoke tests (e.g., shellcheck lint, sourcing checks) and document how to run them.

## Common Tasks and Commands
- List all aliases currently available:
  ```bash
  alias
  ```
- Check that sourcing works without errors:
  ```bash
  bash -lc 'source ./aliases.sh; source ./functions.sh; echo OK'
  ```
- Lint the scripts with shellcheck (if installed):
  ```bash
  shellcheck aliases.sh functions.sh
  ```

## Compatibility Notes
- The `www` alias assumes a Debian/Ubuntu-style Apache web root at `/var/www/html/`.
- The `reload` alias assumes specific service names and systemd; modify for your OS/distro as needed.

## License
- TODO: Add a license file (e.g., MIT, Apache-2.0) or clarify licensing terms.

## Contributing
- Feel free to propose additional helpful aliases or functions. Keep portability in mind and add comments for OS/distro-specific items.
