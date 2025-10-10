#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# A simple script to gather and display IP or domain information
# Usage: ipinfo <IP-or-domain>
# Ensure required tools are installed
if ! command -v whois &> /dev/null || ! command -v geoiplookup &> /dev/null || ! command -v dig &> /dev/null || ! command -v traceroute &> /dev/null || ! command -v nmap &> /dev/null; then
    echo "This script requires 'whois', 'geoiplookup', 'dig', 'traceroute', and 'nmap' to be installed."
    echo "Please install them using your package manager."
    exit 1
fi

ipinfo() {
    if [ -z "$1" ]; then
        echo "Usage: ipinfo <IP-or-domain>"
        return 1
    fi

    local target="$1"

    echo "=== IP Information for: $target ==="
    echo
    echo  "[1/6] WHOIS Lookup"
    whois "$target" | grep -E "OrgName|OrgTechEmail|OrgTechName|abuse|country|Country|netname" --ignore-case

    echo
    echo "[2/6] GeoIP Location"
    geoiplookup "$target"

    echo
    echo "[3/6] Reverse DNS"
    dig -x "$target" +short

    echo
    echo "[4/6] Traceroute"
    traceroute -n "$target" | head -n 10

    echo
    echo "[5/6] Open Ports (Quick Scan)"
    nmap --top-ports 10 "$target"

    echo
    echo "[6/6] Full Service Detection (Common Ports)"
    nmap -sV "$target"

    echo "=== End of report for $target ==="
}
