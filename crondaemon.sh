#!/bin/bash
set -euo pipefail

echo "[+] Enabling and starting the cron daemon..."

if systemctl list-unit-files | grep -q '^cron.service'; then
    sudo systemctl enable cron
    sudo systemctl start cron
    echo "[+] Cron daemon enabled and started."
else
    echo "[!] Cron service not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y cron
    sudo systemctl enable cron
    sudo systemctl start cron
    echo "[+] Cron installed and running."
fi
