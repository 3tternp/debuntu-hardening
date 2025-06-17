#!/bin/bash
# Script to configure secure default file permissions in syslog-ng

set -euo pipefail

echo "[+] Checking if syslog-ng is installed..."
if ! command -v syslog-ng >/dev/null 2>&1; then
  echo "[!] syslog-ng not found. Installing..."
  sudo apt-get update && sudo apt-get install -y syslog-ng
else
  echo "[+] syslog-ng is already installed."
fi

CONFIG_FILE="/etc/syslog-ng/syslog-ng.conf"

echo "[+] Backing up syslog-ng config to ${CONFIG_FILE}.bak"
sudo cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

echo "[+] Setting default log file permissions to 0600..."

# Check if options block exists
if grep -q "^options {" "$CONFIG_FILE"; then
  # Add perm(0600); inside existing options block if not already present
  if ! grep -q "perm(0600);" "$CONFIG_FILE"; then
    sudo sed -i '/^options {/ s/$/ perm(0600);/' "$CONFIG_FILE"
    echo "[+] 'perm(0600);' added to options block."
  else
    echo "[+] 'perm(0600);' already configured."
  fi
else
  # Add a new options block at the top
  echo "options { perm(0600); };" | sudo tee -a "$CONFIG_FILE" >/dev/null
  echo "[+] 'options { perm(0600); };' block added."
fi

echo "[+] Restarting syslog-ng service..."
sudo systemctl restart syslog-ng

echo "[✅] Syslog-ng default file permissions secured (0600)."
