#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

log "Configuring auditd to retain logs safely..."

AUDITD_CONF="/etc/audit/auditd.conf"

# Set KEEP_LOGS and limit number of rotated logs
sed -i '/^max_log_file_action/d' "$AUDITD_CONF"
sed -i '/^num_logs/d' "$AUDITD_CONF"

echo 'max_log_file_action = KEEP_LOGS' >> "$AUDITD_CONF"
echo 'num_logs = 10' >> "$AUDITD_CONF"

log "Restarting auditd to apply changes..."
systemctl restart auditd

log "Audit logs retention policy updated: logs will not be deleted prematurely."
