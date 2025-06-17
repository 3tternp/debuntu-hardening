#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

log "Checking for Telnet client..."

if dpkg -l | grep -qw telnet; then
  log "Telnet client is installed. Removing..."
  apt-get purge -y telnet
  log "Telnet client removed successfully."
else
  log "Telnet client is not installed. No action needed."
fi

exit 0
