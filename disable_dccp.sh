#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

CONFIG_FILE="/etc/modprobe.d/disable-dccp.conf"

log "Disabling DCCP protocol..."

# Prevent future loading
if ! grep -q "^install dccp /bin/true" "$CONFIG_FILE" 2>/dev/null; then
  echo "install dccp /bin/true" >> "$CONFIG_FILE"
  log "Added 'install dccp /bin/true' to $CONFIG_FILE"
fi

# Unload if already loaded
if lsmod | grep -q "^dccp"; then
  modprobe -r dccp && log "Unloaded DCCP module"
fi

log "DCCP disabled successfully."
