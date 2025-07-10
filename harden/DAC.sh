#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

AUDIT_FILE="/etc/audit/rules.d/dac-permission.rules"

log "Creating audit rules for DAC permission changes..."

cat << 'EOF' > "$AUDIT_FILE"
# Audit DAC permission modification events - 64-bit and 32-bit
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b32 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod
EOF

log "Restarting auditd to apply rules..."
systemctl restart auditd

log "DAC permission modification audit rules applied successfully."
