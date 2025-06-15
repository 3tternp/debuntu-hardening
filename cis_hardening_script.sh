#!/bin/bash
# CIS Benchmark Level 1 - Debian/Ubuntu Hardening Script
# Note: Use with caution. Test in non-production environments first.
# This script applies only the failed items listed in the audit report

set -euo pipefail
IFS=$'\n\t'

log() {
  echo "[+] $1"
}

# Function to disable file systems
disable_filesystem() {
  local fs="$1"
  if ! grep -q "$fs" /etc/modprobe.d/cis-hardening.conf 2>/dev/null; then
    echo "install $fs /bin/true" >> /etc/modprobe.d/cis-hardening.conf
    modprobe -r $fs || true
    log "$fs filesystem disabled"
  fi
}

log "Disabling unused filesystem modules..."
disable_filesystem cramfs
disable_filesystem squashfs
disable_filesystem udf
disable_filesystem vfat  # FAT

echo -e "\n# Temporary Filesystem Mount Options Hardening" >> /etc/fstab
log "Remounting /tmp with secure options..."
mount -o remount,nodev,nosuid,noexec /tmp || true
sed -i '/\/tmp/d' /etc/fstab
echo "tmpfs /tmp tmpfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab

log "Remounting /var/tmp with secure options..."
mkdir -p /var/tmp
mount -o remount,nodev,nosuid,noexec /var/tmp || true
sed -i '/\/var\/tmp/d' /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab

log "Remounting /dev/shm with noexec option..."
mount -o remount,noexec /dev/shm || true
sed -i '/\/dev\/shm/d' /etc/fstab
echo "tmpfs /dev/shm tmpfs defaults,nodev,nosuid,noexec 0 0" >> /etc/fstab

log "Setting sticky bit on world-writable directories..."
find / -xdev -type d -perm -0002 -exec chmod +t {} +

log "Disabling automounting..."
systemctl disable autofs || true

log "Configuring package manager to enforce GPG checking..."
sed -i 's/^# *APT::Get::AllowUnauthenticated .*$/APT::Get::AllowUnauthenticated "false";/' /etc/apt/apt.conf.d/* || true

log "Installing AIDE for file integrity monitoring..."
apt-get update && apt-get install aide aide-common -y
/usr/sbin/aideinit
cp /var/lib/aide/aide.db.new /var/lib/aide/aide.db

log "Restricting core dumps..."
echo '* hard core 0' >> /etc/security/limits.conf
sysctl -w fs.suid_dumpable=0

log "Disabling prelink (if installed)..."
apt-get remove prelink -y || true

log "Ensuring bootloader config is secured..."
chmod 600 /boot/grub/grub.cfg

log "Setting bootloader password (manual step required)"
echo "Manual: Edit /etc/grub.d/40_custom and add GRUB password"

log "Ensuring SELinux is installed and enforcing (if applicable)..."
apt-get install selinux-basics selinux-policy-default -y
selinux-activate || true

log "Restricting xinetd service..."
systemctl disable xinetd || true

log "Disabling unnecessary services..."
services=(avahi-daemon cups isc-dhcp-server slapd nfs-kernel-server bind9 vsftpd apache2 dovecot smbd squid snmpd nis rsh-server telnetd tftpd talkd)
for svc in "${services[@]}"; do
  systemctl disable "$svc" 2>/dev/null || true
  apt-get purge -y "$svc" 2>/dev/null || true
  log "$svc disabled and removed"
done

log "Configuring firewall with default deny policy..."
apt-get install iptables -y
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables-save > /etc/iptables/rules.v4

log "Installing and enabling auditd..."
apt-get install auditd audispd-plugins -y
systemctl enable auditd
systemctl start auditd

log "Securing SSH configuration..."
sed -i 's/^#\?Protocol .*/Protocol 2/' /etc/ssh/sshd_config
sed -i 's/^#\?LogLevel .*/LogLevel INFO/' /etc/ssh/sshd_config
sed -i 's/^#\?X11Forwarding .*/X11Forwarding no/' /etc/ssh/sshd_config
sed -i 's/^#\?MaxAuthTries .*/MaxAuthTries 4/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitEmptyPasswords .*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
sed -i 's/^#\?ClientAliveInterval .*/ClientAliveInterval 300/' /etc/ssh/sshd_config
sed -i 's/^#\?ClientAliveCountMax .*/ClientAliveCountMax 0/' /etc/ssh/sshd_config
systemctl reload sshd

log "Updating system packages..."
apt-get upgrade -y

log "Hardening complete. Please reboot to ensure all changes take effect."

exit 0
