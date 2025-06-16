#!/bin/bash

# Disable mounting of cramfs filesystem
echo "🚫 Disabling cramfs filesystem support..."

# 1. Add module block to modprobe blacklist
echo "install cramfs /bin/true" | sudo tee /etc/modprobe.d/cramfs.conf

# 2. Prevent module from auto-loading (precaution)
echo "blacklist cramfs" | sudo tee -a /etc/modprobe.d/cramfs.conf

# 3. Unload cramfs if already loaded
if lsmod | grep -q cramfs; then
    echo "🔁 Unloading cramfs module..."
    sudo rmmod cramfs
else
    echo "✅ cramfs module not currently loaded."
fi

# 4. Verify
echo "🔍 Verifying cramfs block..."
grep cramfs /etc/modprobe.d/cramfs.conf

echo "✅ Cramfs filesystem is now disabled per CIS benchmark."
