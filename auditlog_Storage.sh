#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

log "Configuring audit log storage size..."

# Set max_log_file to 4096 (4GB) in auditd.conf, replace if existing
if grep -q '^max_log_file' /etc/audit/auditd.conf; then
    sed -i 's/^max_log_file.*/max_log_file = 4096/' /etc/audit/auditd.conf
else
    echo 'max_log_file = 4096' >> /etc/audit/auditd.conf
fi

log "Restarting auditd service to apply changes..."
systemctl restart auditd

log "Audit log storage size configured to 4GB successfully."
