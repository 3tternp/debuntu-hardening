#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log"
LOG_GROUP="adm"  # Adjust if different on your system

echo "[+] Setting secure permissions on all log files under $LOG_DIR ..."

# Set ownership and permissions recursively for files only
find "$LOG_DIR" -type f -exec chown root:"$LOG_GROUP" {} \;
find "$LOG_DIR" -type f -exec chmod 640 {} \;

echo "[+] Permissions and ownership set successfully."
