#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

IMMUTABLE_RULE_FILE="/etc/audit/rules.d/99-finalize.rules"

echo "[+] Configuring auditd to make audit rules immutable..."

if grep -q "^-e 2" "$IMMUTABLE_RULE_FILE" 2>/dev/null; then
    echo "[✓] Immutable rule already configured."
else
    echo "-e 2" >> "$IMMUTABLE_RULE_FILE"
    echo "[+] Immutable rule added to $IMMUTABLE_RULE_FILE"
fi

echo "[+] Restarting auditd to apply changes..."
systemctl restart auditd

echo "[✓] Audit configuration is now set to immutable. Reboot required to make changes again."
