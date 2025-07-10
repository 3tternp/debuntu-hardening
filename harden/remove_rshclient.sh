#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

log "Checking for rsh client utilities..."

if dpkg -l | grep -Eqw 'rsh-client|rsh-redone-client'; then
  log "rsh client packages found. Removing..."
  apt-get purge -y rsh-client rsh-redone-client
  log "rsh client utilities successfully removed."
else
  log "rsh clients are not installed. No action needed."
fi

exit 0
