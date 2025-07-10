#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

REMOTE_LOG_HOST="LOG_SERVER_IP"
REMOTE_LOG_PORT="514"   # default port; change if needed
RSYSLOG_CONF="/etc/rsyslog.d/90-remote.conf"

echo "[+] Configuring rsyslog to send logs to remote host $REMOTE_LOG_HOST:$REMOTE_LOG_PORT..."

if grep -q "$REMOTE_LOG_HOST" "$RSYSLOG_CONF" 2>/dev/null; then
  echo "[✓] Remote log host already configured."
else
  echo "*.* @@${REMOTE_LOG_HOST}:${REMOTE_LOG_PORT}" > "$RSYSLOG_CONF"
  echo "[+] Remote log forwarding configured in $RSYSLOG_CONF"
fi

echo "[+] Restarting rsyslog service..."
systemctl restart rsyslog

echo "[✓] rsyslog configured to forward logs to remote host."
