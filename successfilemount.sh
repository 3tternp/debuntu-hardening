#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

RULES_FILE="/etc/audit/rules.d/successful-mounts.rules"

log "Creating audit rules for successful filesystem mounts..."

cat << 'EOF' > "$RULES_FILE"
# Audit successful filesystem mounts (exit code 0)
-a always,exit -F arch=b64 -S mount -F exit=0 -k fs_mount
-a always,exit -F arch=b32 -S mount -F exit=0 -k fs_mount
EOF

log "Restarting auditd to apply new rules..."
systemctl restart auditd

log "Audit rules for successful filesystem mounts configured."
