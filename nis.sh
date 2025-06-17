#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

log "Checking if NIS client is installed..."

if dpkg -l | grep -qw nis; then
  log "NIS client detected. Removing..."
  apt-get purge -y nis
  log "NIS client successfully removed."
else
  log "NIS client is not installed. No action needed."
fi

exit 0
