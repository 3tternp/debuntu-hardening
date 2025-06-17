#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

AUDIT_RULES_FILE="/etc/audit/rules.d/failed-file-access.rules"

log "Creating persistent audit rules for failed unauthorized file access..."

cat << 'EOF' > "$AUDIT_RULES_FILE"
# Audit unsuccessful unauthorized file access attempts (exit code = -EACCES)
-a always,exit -F arch=b64 -S open,openat,creat,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access_failed
-a always,exit -F arch=b32 -S open,openat,creat,truncate,ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -k access_failed
EOF

log "Restarting auditd to apply the new rules..."
systemctl restart auditd

log "Audit rules for failed file access attempts configured successfully."
