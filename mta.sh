#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

log "Checking for Postfix installation..."

if dpkg -l | grep -qw postfix; then
  log "Postfix is installed. Configuring it for local-only mode..."
  postconf -e 'inet_interfaces = loopback-only'
  systemctl restart postfix
  log "Postfix configured to listen only on localhost (loopback-only)."
else
  log "Postfix is not installed. No changes made."
fi

exit 0
