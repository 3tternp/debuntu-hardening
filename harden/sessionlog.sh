#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

AUDIT_FILE="/etc/audit/rules.d/session-init.rules"

log "Creating persistent audit rules for session initiation..."

cat << 'EOF' > "$AUDIT_FILE"
# Audit execve calls where effective UID != UID (user switching or privilege escalation)
-a always,exit -F arch=b64 -S execve -C uid!=euid -k session
-a always,exit -F arch=b32 -S execve -C uid!=euid -k session
EOF

log "Restarting auditd to activate new rules..."
systemctl restart auditd

log "Audit rule for session initiation events has been configured."
