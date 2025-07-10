#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

AUDIT_RULES_FILE="/etc/audit/rules.d/time-change.rules"

log "Creating persistent audit rules for time/date modifications..."

cat << 'EOF' > "$AUDIT_RULES_FILE"
# Audit rules for date/time change detection
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change

# If using 32-bit system or 32-bit apps on 64-bit OS
-a always,exit -F arch=b32 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b32 -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change
EOF

log "Restarting auditd to apply rules..."
systemctl restart auditd

log "Audit rules for time/date modification have been added and activated."
