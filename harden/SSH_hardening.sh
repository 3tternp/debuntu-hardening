#!/bin/bash

# SSH Hardening Script
# Purpose: Secure SSH configuration by limiting access to a specific user and custom port

set -euo pipefail
IFS=$'\n\t'

# Prompt for username and port
read -p "Enter the username you want to allow SSH access for: " SSH_USER
read -p "Enter the SSH port you want to use (default: 22): " SSH_PORT
SSH_PORT=${SSH_PORT:-22}

# Create user if not exists
if id "$SSH_USER" &>/dev/null; then
    echo "[+] User '$SSH_USER' already exists."
else
    echo "[+] Creating user '$SSH_USER'..."
    adduser --disabled-password --gecos "" "$SSH_USER"
fi

# Configure SSHD
SSHD_CONFIG="/etc/ssh/sshd_config"

echo "[+] Backing up current SSH configuration..."
cp "$SSHD_CONFIG" "$SSHD_CONFIG.bak.$(date +%F-%T)"

echo "[+] Applying hardening settings to SSH configuration..."

sed -i "s/^#*Port .*/Port $SSH_PORT/" "$SSHD_CONFIG"
sed -i "s/^#*PermitRootLogin .*/PermitRootLogin no/" "$SSHD_CONFIG"
sed -i "s/^#*PasswordAuthentication .*/PasswordAuthentication no/" "$SSHD_CONFIG"
sed -i "s/^#*ChallengeResponseAuthentication .*/ChallengeResponseAuthentication no/" "$SSHD_CONFIG"
sed -i "s/^#*UsePAM .*/UsePAM yes/" "$SSHD_CONFIG"
sed -i "s/^#*X11Forwarding .*/X11Forwarding no/" "$SSHD_CONFIG"
sed -i "s/^#*AllowUsers .*/AllowUsers $SSH_USER/" "$SSHD_CONFIG"

# In case AllowUsers is not present
grep -q "^AllowUsers" "$SSHD_CONFIG" || echo "AllowUsers $SSH_USER" >> "$SSHD_CONFIG"

echo "[+] Restarting SSH service..."
systemctl restart sshd

echo "[+] SSH hardening complete. SSH is now restricted to user '$SSH_USER' on port $SSH_PORT."
