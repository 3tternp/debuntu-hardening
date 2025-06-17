#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

# Install rsyslog if not present
if ! dpkg -l | grep -qw rsyslog; then
  log "Installing rsyslog..."
  apt-get update && apt-get install -y rsyslog
fi

# Enable and start rsyslog
log "Enabling and starting rsyslog..."
systemctl enable rsyslog
systemctl restart rsyslog

# Ensure logrotate is installed
if ! dpkg -l | grep -qw logrotate; then
  log "Installing logrotate..."
  apt-get install -y logrotate
fi

# Ensure basic syslog config exists
RSYSLOG_CONF="/etc/rsyslog.conf"
if ! grep -q "/var/log/syslog" "$RSYSLOG_CONF"; then
  log "Adding default syslog logging rules..."
  echo "*.* /var/log/syslog" >> "$RSYSLOG_CONF"
  systemctl restart rsyslog
fi

# Test if logging works
logger "Logging test message from hardening script."

log "Logging configuration completed successfully."
