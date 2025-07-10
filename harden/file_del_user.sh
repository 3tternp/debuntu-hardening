#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

RULES_FILE="/etc/audit/rules.d/file-deletion.rules"

log "Configuring audit rules for user file deletion events..."

cat << 'EOF' > "$RULES_FILE"
# Audit file deletion and rename syscalls by non-system users
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=4294967295 -k file_deletion
-a always,exit -F arch=b32 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=4294967295 -k file_deletion
EOF

log "Restarting auditd service to apply new rules..."
systemctl restart auditd

log "Audit rules for file deletion events applied."
