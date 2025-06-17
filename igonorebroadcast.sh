#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

log "Ignoring broadcast ICMP echo requests (runtime)..."
sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1

log "Making setting persistent in /etc/sysctl.conf..."
sed -i '/^net.ipv4.icmp_echo_ignore_broadcasts/d' /etc/sysctl.conf
echo "net.ipv4.icmp_echo_ignore_broadcasts = 1" >> /etc/sysctl.conf

log "Applying sysctl changes..."
sysctl -p

log "Broadcast ICMP echo requests are now ignored (secured)."

exit 0
