#!/bin/bash

set -e

echo "[*] Starting system remediation..."

# 1. Blacklist unwanted filesystems and modules
declare -a MODULES=("cramfs" "freevxfs" "jffs2" "hfs" "hfsplus" "udf" "usb-storage")
for mod in "${MODULES[@]}"; do
    CONF_FILE="/etc/modprobe.d/${mod}.conf"
    echo "install $mod /bin/true" > "$CONF_FILE"
    echo "[+] Wrote $CONF_FILE"
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

# 3. Harden /dev/shm via /etc/fstab
sed -i '/\/dev\/shm/d' /etc/fstab
echo "tmpfs /dev/shm tmpfs defaults,noexec,nodev,nosuid,seclabel 0 0" >> /etc/fstab
mount -o remount,noexec,nodev,nosuid /dev/shm
echo "[+] /dev/shm hardened"

# 4. Harden /var/tmp using fstab (assuming it's a separate partition)
sed -i '/\/var\/tmp/d' /etc/fstab
echo "tmpfs /var/tmp tmpfs defaults,nosuid,nodev,noexec 0 0" >> /etc/fstab
mount -o remount,nosuid,nodev,noexec /var/tmp
echo "[+] /var/tmp hardened"

# 5. Harden /home if separate
if grep -q "/home" /etc/fstab; then
    sed -i '/\/home/d' /etc/fstab
    echo "UUID=$(blkid -o value -s UUID $(df --output=source /home | tail -n1)) /home ext4 defaults,nodev 0 2" >> /etc/fstab
    mount -o remount,nodev /home
    echo "[+] /home hardened"
fi

# 6. Harden removable media (e.g. floppy, cdrom)
sed -i '/floppy\|cdrom/d' /etc/fstab
echo "# Example removable media mount entries" >> /etc/fstab
echo "/dev/fd0 /media/floppy auto defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
echo "/dev/cdrom /media/cdrom auto defaults,noexec,nosuid,nodev 0 0" >> /etc/fstab
echo "[+] Removable media mount options secured"

# 7. Harden world-writable dirs (sticky bit)
echo "[*] Setting sticky bit on world-writable directories..."
df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null | xargs -I '{}' chmod a+t '{}'

# 8. Disable autofs
if systemctl is-enabled autofs &>/dev/null; then
    systemctl --now disable autofs || true
    apt purge -y autofs || true
    echo "[+] autofs disabled and removed"
fi

echo "[✓] Remediation completed. Review /etc/fstab and reboot if needed."
