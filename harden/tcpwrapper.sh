#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

log "Installing TCP Wrappers (tcpd)..."
apt-get update && apt-get install tcpd -y

log "Creating default deny policy in /etc/hosts.deny..."
echo "ALL: ALL" > /etc/hosts.deny

log "Allowing localhost and SSH in /etc/hosts.allow..."
echo "ALL: 127.0.0.1" > /etc/hosts.allow
echo "sshd: ALL" >> /etc/hosts.allow

log "TCP Wrappers installed and basic access rules applied."
log "Ensure your services are linked to libwrap (libwrap0) if needed."

exit 0
