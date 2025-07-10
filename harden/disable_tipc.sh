#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

CONFIG_FILE="/etc/modprobe.d/disable-tipc.conf"

log "Disabling TIPC protocol..."

# Block loading the module in future
if ! grep -q "^install tipc /bin/true" "$CONFIG_FILE" 2>/dev/null; then
  echo "install tipc /bin/true" >> "$CONFIG_FILE"
  log "Rule added to $CONFIG_FILE"
fi

# Unload if currently loaded
if lsmod | grep -q "^tipc"; then
  modprobe -r tipc && log "TIPC module unloaded"
fi

log "TIPC has been successfully disabled."
