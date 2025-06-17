#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

log() { echo "[+] $1"; }

# Ensure tcpd is installed
if ! dpkg -s tcpd &> /dev/null; then
  log "Installing TCP Wrappers (tcpd)..."
  apt-get update && apt-get install -y tcpd
fi

# Take user input
read -rp "Enter an IP address to allow (e.g., 10.0.0.5): " ip_address
read -rp "Enter a network CIDR to allow (e.g., 192.168.1.0/24): " network_cidr

# Backup existing configs
timestamp=$(date +%F-%H%M%S)
cp /etc/hosts.allow /etc/hosts.allow.bak.$timestamp 2>/dev/null || true
cp /etc/hosts.deny /etc/hosts.deny.bak.$timestamp 2>/dev/null || true

# Configure /etc/hosts.allow
cat <<EOF > /etc/hosts.allow
# Allow single IP
ALL: $ip_address

# Allow CIDR (services must support it)
ALL: $network_cidr

# Always allow localhost
ALL: 127.0.0.1
EOF

# Configure /etc/hosts.deny
echo "ALL: ALL" > /etc/hosts.deny

log "Configured /etc/hosts.allow and /etc/hosts.deny successfully."
log "Allowed Host/IP: $ip_address, Allowed Network: $network_cidr"
