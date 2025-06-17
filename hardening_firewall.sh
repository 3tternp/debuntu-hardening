#!/bin/bash

set -euo pipefail
IFS=$'\n\t'
log() { echo "[+] $1"; }

log "Installing iptables-persistent if not present..."
apt-get install -y iptables-persistent

log "Flushing existing rules..."
iptables -F
iptables -X

log "Setting default policies..."
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

log "Allowing loopback..."
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -s 127.0.0.0/8 ! -i lo -j DROP

log "Allowing established and related traffic..."
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

log "Adding explicit allow rules for known open ports..."
iptables -A INPUT -p tcp --dport 22 -j ACCEPT     # SSH
iptables -A INPUT -p tcp --dport 80 -j ACCEPT     # HTTP
iptables -A INPUT -p tcp --dport 443 -j ACCEPT    # HTTPS

# OPTIONAL: log dropped packets
# iptables -A INPUT -j LOG --log-prefix "IPTables-Dropped: " --log-level 4

log "Saving firewall rules..."
iptables-save > /etc/iptables/rules.v4

log "Firewall configuration complete. Only specified ports are allowed."
