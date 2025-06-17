#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

log "Disabling IP forwarding (runtime)..."
sysctl -w net.ipv4.ip_forward=0
sysctl -w net.ipv6.conf.all.forwarding=0

log "Disabling IP forwarding (persistent in /etc/sysctl.conf)..."
sed -i '/^net.ipv4.ip_forward/d' /etc/sysctl.conf
sed -i '/^net.ipv6.conf.all.forwarding/d' /etc/sysctl.conf

echo "net.ipv4.ip_forward = 0" >> /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding = 0" >> /etc/sysctl.conf

log "Applying changes..."
sysctl -p

log "IP forwarding has been disabled and persisted."

exit 0
