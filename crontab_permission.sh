#!/bin/bash
set -euo pipefail

echo "[+] Securing /etc/crontab file..."

CRONFILE="/etc/crontab"

# Set ownership to root:root
sudo chown root:root "$CRONFILE"

# Set permission to 600
sudo chmod 600 "$CRONFILE"

echo "[+] /etc/crontab ownership and permissions secured."
