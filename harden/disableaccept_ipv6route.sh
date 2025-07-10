#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

log "Disabling acceptance of IPv6 router advertisements (runtime)..."
sysctl -w net.ipv6.conf.all.accept_ra=0
sysctl -w net.ipv6.conf.default.accept_ra=0

log "Making changes persistent in /etc/sysctl.conf..."
sed -i '/^net.ipv6.conf.all.accept_ra/d' /etc/sysctl.conf
sed -i '/^net.ipv6.conf.default.accept_ra/d' /etc/sysctl.conf

echo "net.ipv6.conf.all.accept_ra = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.accept_ra = 0" >> /etc/sysctl.conf

log "Applying changes..."
sysctl -p

log "IPv6 router advertisements are now ignored."

exit 0
