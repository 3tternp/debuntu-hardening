#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

AUDIT_FILE="/etc/audit/rules.d/mac-policy.rules"

log "Creating audit rules for MAC system configuration changes..."

cat << 'EOF' > "$AUDIT_FILE"
# Watch SELinux configuration directory
-w /etc/selinux/ -p wa -k MAC-policy

# Watch AppArmor configuration directory
-w /etc/apparmor/ -p wa -k MAC-policy
EOF

log "Restarting auditd to apply changes..."
systemctl restart auditd

log "Audit rules for MAC (SELinux/AppArmor) modifications have been added."
