#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

log "Disabling IPv6 (runtime)..."
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

log "Making IPv6 disablement persistent..."
sed -i '/^net.ipv6.conf.all.disable_ipv6/d' /etc/sysctl.conf
sed -i '/^net.ipv6.conf.default.disable_ipv6/d' /etc/sysctl.conf

echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf

log "Applying sysctl settings..."
sysctl -p

log "IPv6 has been disabled. A reboot is recommended for complete effect."

exit 0
