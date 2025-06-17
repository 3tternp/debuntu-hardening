#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

AUDIT_FILE="/etc/audit/rules.d/privileged-commands.rules"

log "Configuring audit rules for privileged command usage..."

cat << 'EOF' > "$AUDIT_FILE"
# Audit execution of commands by root (euid=0)
-a always,exit -F arch=b64 -S execve -F euid=0 -k privileged_cmd
-a always,exit -F arch=b32 -S execve -F euid=0 -k privileged_cmd
EOF

log "Restarting auditd to apply new rules..."
systemctl restart auditd

log "Audit rules for privileged command usage applied successfully."
