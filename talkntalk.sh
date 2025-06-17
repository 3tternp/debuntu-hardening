#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

log "Checking for talk client packages..."

clients=(talk ytalk ntalk)
removed=false

for client in "${clients[@]}"; do
  if dpkg -l | grep -qw "$client"; then
    log "$client is installed. Removing..."
    apt-get purge -y "$client"
    removed=true
  fi
done

if [ "$removed" = false ]; then
  log "No talk clients are installed. No action needed."
fi

exit 0
