#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

LOG_PATH="/var/log/sudo.log"
RULE_FILE="/etc/audit/rules.d/sudolog.rules"

echo "[+] Creating persistent audit rule for sudo actions..."

if [ ! -f "$LOG_PATH" ]; then
  echo "[!] $LOG_PATH does not exist. Adjusting to common alternative: /var/log/auth.log"
  LOG_PATH="/var/log/auth.log"
fi

cat << EOF > "$RULE_FILE"
-w $LOG_PATH -p wa -k sudolog
EOF

echo "[+] Restarting auditd to apply changes..."
systemctl restart auditd

echo "[+] Audit rule for sudo log applied and persistent (file monitored: $LOG_PATH)."
