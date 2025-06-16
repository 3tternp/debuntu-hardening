#!/bin/bash

# Disable mounting of freevxfs filesystem
echo "🚫 Disabling freevxfs filesystem support..."

# 1. Block module from loading
echo "install freevxfs /bin/true" | sudo tee /etc/modprobe.d/freevxfs.conf

# 2. Add blacklist line (optional but recommended)
echo "blacklist freevxfs" | sudo tee -a /etc/modprobe.d/freevxfs.conf

# 3. Unload the module if it’s already loaded
if lsmod | grep -q freevxfs; then
    echo "🔁 Unloading loaded freevxfs module..."
    sudo rmmod freevxfs
else
    echo "✅ freevxfs module is not currently loaded."
fi

# 4. Verify
echo "🔍 Verifying freevxfs block status..."
modprobe -n -v freevxfs

echo "✅ freevxfs filesystem module has been disabled."
