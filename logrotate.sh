#!/bin/bash
set -euo pipefail

echo "[+] Installing logrotate if not present..."
if ! command -v logrotate >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y logrotate
    echo "[+] logrotate installed."
else
    echo "[+] logrotate already installed."
fi

LOGROTATE_CONF="/etc/logrotate.conf"
BACKUP_CONF="/etc/logrotate.conf.bak.$(date +%F-%T)"

echo "[+] Backing up existing logrotate config to $BACKUP_CONF"
sudo cp "$LOGROTATE_CONF" "$BACKUP_CONF"

# Minimal example: rotate logs weekly, keep 4 weeks, compress old logs
sudo tee "$LOGROTATE_CONF" > /dev/null << EOF
weekly
rotate 4
compress
missingok
notifempty
create 640 root adm
include /etc/logrotate.d
EOF

echo "[+] Basic logrotate configuration applied."
echo "[+] Please customize /etc/logrotate.conf or /etc/logrotate.d/* for specific log files as needed."
