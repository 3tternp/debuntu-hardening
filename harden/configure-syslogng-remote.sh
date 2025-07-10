#!/bin/bash

set -euo pipefail

read -rp "Enter remote log server IP or hostname: " REMOTE_LOG_HOST
read -rp "Enter port (default 514): " REMOTE_LOG_PORT
REMOTE_LOG_PORT=${REMOTE_LOG_PORT:-514}

read -rp "Protocol to use (tcp/udp) [tcp]: " PROTOCOL
PROTOCOL=${PROTOCOL:-tcp}

CONFIG_FILE="/etc/syslog-ng/syslog-ng.conf"
BACKUP_FILE="/etc/syslog-ng/syslog-ng.conf.bak"

echo "[+] Backing up $CONFIG_FILE to $BACKUP_FILE"
sudo cp "$CONFIG_FILE" "$BACKUP_FILE"

echo "[+] Configuring syslog-ng to forward logs to $REMOTE_LOG_HOST:$REMOTE_LOG_PORT over $PROTOCOL..."

# Add destination and log statement if not already present
sudo tee -a "$CONFIG_FILE" >/dev/null <<EOF

# Remote log host configuration
destination d_remote {
    ${PROTOCOL}("${REMOTE_LOG_HOST}" port(${REMOTE_LOG_PORT}));
};

log {
    source(s_src);
    destination(d_remote);
};
EOF

echo "[+] Restarting syslog-ng service..."
sudo systemctl restart syslog-ng

echo "[✅] syslog-ng is now configured to send logs to $REMOTE_LOG_HOST:$REMOTE_LOG_PORT over $PROTOCOL"
