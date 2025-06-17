#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

CONFIG_FILE="/etc/modprobe.d/disable-sctp.conf"

log "Disabling SCTP protocol..."

# Add rule to prevent loading
if ! grep -q "^install sctp /bin/true" "$CONFIG_FILE" 2>/dev/null; then
  echo "install sctp /bin/true" >> "$CONFIG_FILE"
  log "Rule added to $CONFIG_FILE"
fi

# Remove if loaded
if lsmod | grep -q "^sctp"; then
  modprobe -r sctp && log "SCTP module unloaded"
fi

log "SCTP is now disabled."
