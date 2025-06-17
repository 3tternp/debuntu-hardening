#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

RULES_FILE="/etc/audit/rules.d/sudoers.rules"

log "Configuring audit rules for sudoers changes..."

cat << 'EOF' > "$RULES_FILE"
# Audit changes to sudoers configuration files and directories
-w /etc/sudoers -p wa -k sudoers_changes
-w /etc/sudoers.d/ -p wa -k sudoers_changes
EOF

log "Restarting auditd to apply new rules..."
systemctl restart auditd

log "Audit rules for sudoers changes applied."
