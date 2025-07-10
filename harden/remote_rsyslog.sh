#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

RSYSLOG_CONF="/etc/rsyslog.conf"

echo "[*] Enter comma-separated list of trusted IPs or networks (e.g., 127.0.0.1,192.168.1.10,10.0.0.0/24):"
read -rp "Trusted IP(s): " TRUSTED_SENDERS

# Validate non-empty input
if [[ -z "$TRUSTED_SENDERS" ]]; then
    echo "[!] No IPs provided. Exiting."
    exit 1
fi

echo "[+] Restricting rsyslog to allow only: $TRUSTED_SENDERS"

# Backup config
cp "$RSYSLOG_CONF" "${RSYSLOG_CONF}.bak"

# Apply or update AllowedSender rule
if grep -q '^\$AllowedSender' "$RSYSLOG_CONF"; then
    sed -i "s|^\$AllowedSender.*|\$AllowedSender TCP,$TRUSTED_SENDERS|" "$RSYSLOG_CONF"
else
    echo "\$AllowedSender TCP,$TRUSTED_SENDERS" >> "$RSYSLOG_CONF"
fi

# Restart rsyslog to apply changes
systemctl restart rsyslog

echo "[✓] rsyslog configured to only accept from: $TRUSTED_SENDERS"
