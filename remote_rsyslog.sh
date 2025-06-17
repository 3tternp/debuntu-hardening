#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

TRUSTED_SENDERS="127.0.0.1,192.168.1.10"   # <-- Replace with your trusted IP(s)
RSYSLOG_CONF="/etc/rsyslog.conf"

echo "[+] Restricting rsyslog remote message sources to: $TRUSTED_SENDERS"

if grep -q '^\$AllowedSender' "$RSYSLOG_CONF"; then
    sed -i "s/^\$AllowedSender.*/\$AllowedSender TCP,$TRUSTED_SENDERS/" "$RSYSLOG_CONF"
else
    echo "\$AllowedSender TCP,$TRUSTED_SENDERS" >> "$RSYSLOG_CONF"
fi

echo "[+] Restarting rsyslog..."
systemctl restart rsyslog

echo "[✓] rsyslog now only accepts messages from: $TRUSTED_SENDERS"
