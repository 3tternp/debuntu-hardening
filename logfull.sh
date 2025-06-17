#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

log "Configuring auditd to halt system when audit logs are full..."

# Set max_log_file_action to HALT in auditd.conf, replace if existing
if grep -q '^max_log_file_action' /etc/audit/auditd.conf; then
    sed -i 's/^max_log_file_action.*/max_log_file_action = HALT/' /etc/audit/auditd.conf
else
    echo 'max_log_file_action = HALT' >> /etc/audit/auditd.conf
fi

log "Restarting auditd service to apply changes..."
systemctl restart auditd

log "Auditd configured to halt system when audit logs are full."
