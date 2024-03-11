#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Backup existing SSH configuration
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Modify SSH configuration settings
echo "Changing SSH port to a non-standard value (e.g., 2345)"
sed -i 's/#Port 22/Port 2345/g' /etc/ssh/sshd_config

echo "Disabling password-based authentication"
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

echo "Limiting login attempts"
echo "MaxAuthTries 3" >> /etc/ssh/sshd_config

echo "Restricting root login (Ensure alternative access!)"
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Optional: Consider these additional settings
echo "Setting idle timeout"
echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config

echo "Allowing only specific users or groups (modify as needed)"
echo "AllowUsers user1 user2" >> /etc/ssh/sshd_config

# Restart SSH for changes to take effect
systemctl restart sshd

# Script completion message
echo "SSH hardening complete. Remember to update firewall rules for the new port."
