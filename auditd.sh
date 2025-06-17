#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

log "Installing auditd and dependencies..."
apt-get update -y
apt-get install -y auditd audispd-plugins

log "Enabling auditd to start at boot..."
systemctl enable auditd

log "Starting auditd service..."
systemctl start auditd

log "Verifying auditd status..."
if systemctl is-active --quiet auditd; then
    log "auditd is running successfully."
else
    echo "[!] auditd failed to start. Check journal logs."
    exit 1
fi
