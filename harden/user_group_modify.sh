#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

AUDIT_RULES_FILE="/etc/audit/rules.d/user-group-mod.rules"

log "Creating persistent audit rules for user/group modification events..."

cat << 'EOF' > "$AUDIT_RULES_FILE"
# Watch for changes to user and group configuration
-w /etc/passwd -p wa -k usergroup_mod
-w /etc/group -p wa -k usergroup_mod
-w /etc/shadow -p wa -k usergroup_mod
-w /etc/gshadow -p wa -k usergroup_mod
EOF

log "Reloading audit rules..."
systemctl restart auditd

log "Audit rules for user/group modification events have been added and activated."
