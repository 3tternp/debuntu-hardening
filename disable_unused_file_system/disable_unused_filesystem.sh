#!/bin/bash

set -euo pipefail

echo "[*] Starting Ubuntu 18.04 CIS hardening..."

# 1. Disable filesystem modules
declare -a FS_MODULES=("cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "udf" "usb-storage" "squashfs" "vfat")
for mod in "${FS_MODULES[@]}"; do
    CONF_FILE="/etc/modprobe.d/${mod}.conf"
    echo "install $mod /bin/true" > "$CONF_FILE"
    echo "[+] Blacklisted module: $mod via $CONF_FILE"
    rmmod "$mod" 2>/dev/null || true
done

# 2. Harden /tmp using systemd mount unit
if [ ! -f /etc/systemd/system/tmp.mount ]; then
    cp -v /usr/share/systemd/tmp.mount /etc/systemd/system/
fi
cat <<EOF > /etc/systemd/system/tmp.mount
[Mount]
What=tmpfs
Where=/tmp
Type=tmpfs
Options=mode=1777,strictatime,nosuid,nodev,noexec
EOF
systemctl daemon-reload
systemctl --now enable tmp.mount
echo "[+] /tmp hardened with tmp.mount"

# 3. Harden /dev/shm
sed -i '/\/dev\/shm/d' /etc/fstab
echo "tmpfs /dev/shm tmpfs defaults,noexec,nodev,nosuid,seclabel 0 0" >> /etc/fstab
mount -o remount,noexec,nodev,nosuid /dev/shm
echo "[+] /dev/shm hardened"

# 4. Harden /var/tmp (assuming separate partition)
sed -i '/\/var\/tmp/d' /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,nosuid,nodev,noexec 0 0" >> /etc/fstab
mount -o remount,nosuid,nodev,noexec /var/tmp
echo "[+] /var/tmp hardened"

# 5. Harden /home (if separate partition)
if grep -q "/home" /etc/fstab; then
    sed -i '/\/home/d' /etc/fstab
    UUID=$(blkid -o value -s UUID "$(df --output=source /home | tail -n1)")
    echo "UUID=$UUID /home ext4 defaults,nodev 0 2" >> /etc/fstab
    mount -o remount,nodev /home
    echo "[+] /home hardened"
fi

# 6. Harden removable media (example: floppy, cdrom)
sed -i '/floppy\|cdrom/d' /etc/fstab
echo "# Hardened removable media example entries:" >> /etc/fstab
echo "/dev/fd0 /media/floppy auto defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
echo "/dev/cdrom /media/cdrom auto defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
echo "[+] Removable media secured"

# 7. Set sticky bit on world-writable directories
echo "[*] Setting sticky bit on world-writable directories..."
df --local -P | awk 'NR!=1 {print $6}' | while read -r mountpoint; do
    find "$mountpoint" -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -exec chmod a+t {} +
done
echo "[+] Sticky bits set"

# 8. Disable or purge autofs
if systemctl is-enabled autofs &>/dev/null; then
    systemctl --now disable autofs || true
    apt purge -y autofs || true
    echo "[+] autofs disabled and removed"
fi

echo "[✓] Full system hardening complete."
echo "🔁 Please reboot the system to apply kernel module changes."
#!/bin/bash

set -euo pipefail

echo "[*] Starting Ubuntu 18.04 CIS hardening..."

# 1. Disable filesystem modules
declare -a FS_MODULES=("cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "udf" "usb-storage" "squashfs" "vfat")
for mod in "${FS_MODULES[@]}"; do
    CONF_FILE="/etc/modprobe.d/${mod}.conf"
    echo "install $mod /bin/true" > "$CONF_FILE"
    echo "[+] Blacklisted module: $mod via $CONF_FILE"
    rmmod "$mod" 2>/dev/null || true
done

# 2. Harden /tmp using systemd mount unit
if [ ! -f /etc/systemd/system/tmp.mount ]; then
    cp -v /usr/share/systemd/tmp.mount /etc/systemd/system/
fi
cat <<EOF > /etc/systemd/system/tmp.mount
[Mount]
What=tmpfs
Where=/tmp
Type=tmpfs
Options=mode=1777,strictatime,nosuid,nodev,noexec
EOF
systemctl daemon-reload
systemctl --now enable tmp.mount
echo "[+] /tmp hardened with tmp.mount"

# 3. Harden /dev/shm
sed -i '/\/dev\/shm/d' /etc/fstab
echo "tmpfs /dev/shm tmpfs defaults,noexec,nodev,nosuid,seclabel 0 0" >> /etc/fstab
mount -o remount,noexec,nodev,nosuid /dev/shm
echo "[+] /dev/shm hardened"

# 4. Harden /var/tmp (assuming separate partition)
sed -i '/\/var\/tmp/d' /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,nosuid,nodev,noexec 0 0" >> /etc/fstab
mount -o remount,nosuid,nodev,noexec /var/tmp
echo "[+] /var/tmp hardened"

# 5. Harden /home (if separate partition)
if grep -q "/home" /etc/fstab; then
    sed -i '/\/home/d' /etc/fstab
    UUID=$(blkid -o value -s UUID "$(df --output=source /home | tail -n1)")
    echo "UUID=$UUID /home ext4 defaults,nodev 0 2" >> /etc/fstab
    mount -o remount,nodev /home
    echo "[+] /home hardened"
fi

# 6. Harden removable media (example: floppy, cdrom)
sed -i '/floppy\|cdrom/d' /etc/fstab
echo "# Hardened removable media example entries:" >> /etc/fstab
echo "/dev/fd0 /media/floppy auto defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
echo "/dev/cdrom /media/cdrom auto defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
echo "[+] Removable media secured"

# 7. Set sticky bit on world-writable directories
echo "[*] Setting sticky bit on world-writable directories..."
df --local -P | awk 'NR!=1 {print $6}' | while read -r mountpoint; do
    find "$mountpoint" -xdev -type d \( -perm -0002 -a ! -perm -1000 \) -exec chmod a+t {} +
done
echo "[+] Sticky bits set"

# 8. Disable or purge autofs
if systemctl is-enabled autofs &>/dev/null; then
    systemctl --now disable autofs || true
    apt purge -y autofs || true
    echo "[+] autofs disabled and removed"
fi

echo "[✓] Full system hardening complete."
echo "🔁 Please reboot the system to apply kernel module changes."

