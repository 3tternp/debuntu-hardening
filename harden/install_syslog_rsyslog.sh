#!/bin/bash

set -euo pipefail

echo "[+] Checking and installing syslog service..."

read -rp "Choose logging service to install (rsyslog/syslog-ng): " choice

if [[ "$choice" == "rsyslog" ]]; then
  sudo apt-get update
  sudo apt-get install -y rsyslog
  sudo systemctl enable --now rsyslog
  echo "[+] rsyslog installed and enabled."
elif [[ "$choice" == "syslog-ng" ]]; then
  sudo apt-get update
  sudo apt-get install -y syslog-ng
  sudo systemctl enable --now syslog-ng
  echo "[+] syslog-ng installed and enabled."
else
  echo "[-] Invalid choice. Please run the script again and enter 'rsyslog' or 'syslog-ng'."
  exit 1
fi
