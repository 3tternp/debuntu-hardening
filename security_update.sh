#!/bin/bash

# Security Update & Hardening Script
# Author: 3tternp
# Date: $(date)
# Description: This script updates Ubuntu & Debian based Linux Distro, installs security patches, and configures basic security tools.

echo "🛠️ Starting system update and hardening process..."

# Step 1: Update package list
echo "🔄 Updating package list..."
sudo apt update -y 

# Step 2: Upgrade all packages
echo "⬆️ Upgrading packages..."
sudo apt upgrade -y

# Step 3: Perform distribution upgrade
echo "🚀 Performing distribution upgrade..."
sudo apt dist-upgrade -y

# Step 4: Install unattended-upgrades
echo "🔧 Installing unattended-upgrades..."
sudo apt install unattended-upgrades -y

# Step 5: Enable unattended-upgrades
echo "⚙️ Enabling automatic security updates..."
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Step 6: Install UFW and configure basic rules
echo "🧱 Installing UFW firewall..."
sudo apt install ufw -y
echo "🔐 Configuring UFW firewall rules..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

# Step 7: Install Fail2Ban
echo "🛡️ Installing Fail2Ban..."
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Step 8: Install and start AppArmor
echo "📦 Installing AppArmor..."
sudo apt install apparmor apparmor-profiles -y
sudo systemctl enable apparmor
sudo systemctl start apparmor

# Step 9: Clean up
echo "🧹 Cleaning up unnecessary packages..."
sudo apt autoremove -y
sudo apt autoclean

# Step 10: Optional reboot message
echo "✅ All updates and security tools installed."
echo "🔁 Reboot your system if prompted to complete kernel updates."

