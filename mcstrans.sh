#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

log "Checking and removing MCS Translation Services (mcstrans) if installed..."

if dpkg -l | grep -qw mcstrans; then
  log "mcstrans is installed. Removing..."
  apt-get purge -y mcstrans
  log "mcstrans successfully removed."
else
  log "mcstrans is not installed. No action needed."
fi

exit 0
