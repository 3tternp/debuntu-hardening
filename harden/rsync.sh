#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

log "Checking if rsync service is installed and enabled..."

if systemctl list-unit-files | grep -qw rsync.service; then
  log "Disabling and stopping rsync service..."
  systemctl disable --now rsync
  log "Rsync service has been disabled."
else
  log "Rsync service is not installed or already disabled."
fi

exit 0
