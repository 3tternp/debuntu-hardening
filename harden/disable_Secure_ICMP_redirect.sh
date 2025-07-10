#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

log "Disabling secure ICMP redirects (runtime)..."
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0

log "Making secure redirect settings persistent..."
sed -i '/^net.ipv4.conf.all.secure_redirects/d' /etc/sysctl.conf
sed -i '/^net.ipv4.conf.default.secure_redirects/d' /etc/sysctl.conf

echo "net.ipv4.conf.all.secure_redirects = 0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.secure_redirects = 0" >> /etc/sysctl.conf

log "Applying sysctl changes..."
sysctl -p

log "Secure ICMP redirects have been disabled and made persistent."

exit 0
