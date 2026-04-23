#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# log <message>
# Prints a message with a timestamp to standard output.
# Usage: log "Starting process"
log() {
    printf "[%s] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

# err <message>
# Prints an error message to standard error (stderr).
# Usage: err "File not found"
err() {
    printf "[ERROR] %s\n" "$*" >&2
}

# require_cmd <command1> <command2> ...
# Checks whether the specified commands are available in the system.
# Returns 1 and prints an error if any command is missing.
# Usage: require_cmd curl tar unzip
require_cmd() {
    for cmd in "$@"; do
        command -v "$cmd" &>/dev/null || {
            err "Required command not found: $cmd"
            return 1
        }
    done
}


# A simple script to gather and display IP or domain information
# Usage: ipinfo <IP-or-domain>
# Ensure required tools are installed
if ! command -v whois &> /dev/null || ! command -v geoiplookup &> /dev/null || ! command -v dig &> /dev/null || ! command -v traceroute &> /dev/null || ! command -v nmap &> /dev/null; then
    echo "This script requires 'whois', 'geoiplookup', 'dig', 'traceroute', and 'nmap' to be installed."
    echo "Please install them using your package manager."
    exit 1
fi

# ipinfo <IP-or-domain>
# Gathers information about an IP address or domain.
# Uses: whois, geoiplookup, dig, traceroute, nmap
# Displays: WHOIS info, GEOIP location, reverse DNS, traceroute (first 10 hops), nmap (top 10 ports & service detection)
# Usage: ipinfo 8.8.8.8
ipinfo() {
    require_cmd whois geoiplookup dig traceroute nmap || return 1

    if [[ $# -ne 1 ]]; then
        err "Usage: ipinfo <IP-or-domain>"
        return 1
    fi

    local target="$1"

    log "IP information for: $target"

    echo "---- WHOIS ----"
    whois "$target" \
        | grep -Ei "orgname|netname|country|abuse|tech" \
        || echo "No WHOIS data"

    echo
    echo "---- GEOIP ----"
    geoiplookup "$target" || echo "GeoIP failed"

    echo
    echo "---- REVERSE DNS ----"
    dig -x "$target" +short || echo "No PTR record"

    echo
    echo "---- TRACEROUTE (first 10 hops) ----"
    traceroute -n "$target" 2>/dev/null | head -n 10

    echo
    echo "---- NMAP (top 10 ports) ----"
    nmap --top-ports 10 --host-timeout 30s "$target"

    echo
    echo "---- NMAP (service detection, common ports) ----"
    nmap -sV --host-timeout 60s "$target"

    log "Done"
}

# sysinfo
# Displays system information: hostname, uptime, kernel version, OS, memory, and disk usage.
# Usage: sysinfo
sysinfo() {
    require_cmd uname uptime free df || return 1

    echo "Hostname : $(hostname)"
    echo "Uptime   : $(uptime -p)"
    echo "Kernel   : $(uname -r)"

    if command -v lsb_release &>/dev/null; then
        echo "OS       : $(lsb_release -ds)"
    else
        echo "OS       : $(grep PRETTY_NAME /etc/os-release | cut -d= -f2)"
    fi

    echo
    echo "Memory:"
    free -h

    echo
    echo "Disk (/):"
    df -h /
}

# psg <pattern>
# Filters processes by a case-insensitive pattern.
# Usage: psg ssh
psg() {
    if [[ $# -ne 1 ]]; then
        err "Usage: psg <pattern>"
        return 1
    fi

    ps aux | awk 'NR==1 || tolower($0) ~ tolower(ARGV[1])' "$1"
}

# ports
# Shows all active TCP/UDP ports and the processes using them.
# Requires: ss
# Usage: ports
ports() {
    require_cmd ss || return 1
    sudo ss -tulpn
}

# port <number>
# Shows which process is using a specific port.
# Requires: ss
# Usage: port 22
port() {
    require_cmd ss || return 1

    if [[ $# -ne 1 ]]; then
        err "Usage: port <number>"
        return 1
    fi

    sudo ss -tulpn | grep ":$1 "
}

# myip
# Displays the machine’s public IP address.
# Requires: curl
# Usage: myip
myip() {
    require_cmd curl || return 1

    curl -fsS https://ipinfo.io/ip || curl -fsS https://ifconfig.me || err "Unable to determine IP"
}

# httpinfo <host>
# Shows HTTP headers and TLS certificate details for a host.
# Requires: curl and openssl
# Usage: httpinfo example.com
httpinfo() {
    require_cmd curl openssl || return 1

    if [[ $# -ne 1 ]]; then
        err "Usage: httpinfo <host>"
        return 1
    fi

    local host="$1"

    echo "---- HTTP HEADERS ----"
    curl -fsSI -L "https://$host"

    echo
    echo "---- TLS CERT ----"
    echo | openssl s_client -servername "$host" -connect "$host:443" 2>/dev/null \
        | openssl x509 -noout -issuer -subject -dates
}

# extract <archive>
# Extracts archives: tar.gz, tar.bz2, tar.xz, zip, or 7z.
# Requires: tar, unzip, 7z
# Usage: extract file.zip
extract() {
    require_cmd tar unzip 7z || return 1

    [[ $# -eq 1 && -f "$1" ]] || {
        err "Usage: extract <archive>"
        return 1
    }

    case "$1" in
        *.tar.gz|*.tgz) tar xzf "$1" ;;
        *.tar.bz2)      tar xjf "$1" ;;
        *.tar.xz)       tar xJf "$1" ;;
        *.zip)          unzip "$1" ;;
        *.7z)           7z x "$1" ;;
        *) err "Unsupported archive type" ;;
    esac
}

# findbig [directory]
# Lists the 20 largest files/folders in a directory (by size).
# Defaults to the current directory if none is specified.
# Usage: findbig /var/log
findbig() {
    local dir="${1:-.}"
    du -ah "$dir" 2>/dev/null | sort -hr | head -n 20
}

# mkcd <dir>
# Creates a directory and immediately changes into it.
# Usage: mkcd newfolder
mkcd() {
    [[ $# -eq 1 ]] || {
        err "Usage: mkcd <dir>"
        return 1
    }

    mkdir -p "$1" && cd "$1"
}
