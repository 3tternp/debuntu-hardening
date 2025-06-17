#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

RULE_FILE="/etc/audit/rules.d/kernel-modules.rules"

echo "[+] Creating audit rules to monitor kernel module load/unload..."

cat << 'EOF' > "$RULE_FILE"
-a always,exit -F arch=b64 -S init_module -S delete_module -k module_chng
-a always,exit -F arch=b32 -S init_module -S delete_module -k module_chng
EOF

echo "[+] Restarting auditd to apply kernel module monitoring..."
systemctl restart auditd

echo "[✓] Audit rules applied and persistent under key: module_chng"
