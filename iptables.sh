#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

log "Installing iptables and persistent firewall rules..."

# Install iptables and persistent save service
apt-get update
apt-get install -y iptables iptables-persistent

log "Enabling persistent firewall service..."
systemctl enable netfilter-persistent
systemctl start netfilter-persistent

log "Setting default deny policy and basic rules..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback and established connections
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Save rules persistently
iptables-save > /etc/iptables/rules.v4

log "iptables installed and default firewall policy applied."
