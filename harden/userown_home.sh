#!/bin/bash

# Purpose: Ensure users own their home directories

echo "🔍 Checking home directory ownership..."

while IFS=: read -r username _ uid _ _ homedir shell; do
    if [ "$uid" -ge 1000 ] && [[ "$shell" != "/usr/sbin/nologin" && "$shell" != "/bin/false" ]]; then
        if [ -d "$homedir" ]; then
            owner=$(stat -c "%U" "$homedir")
            if [ "$owner" != "$username" ]; then
                echo "⚠️  $username does not own $homedir (owned by $owner). Fixing..."
                chown -R "$username":"$username" "$homedir"
            fi
        fi
    fi
done < /etc/passwd

echo "✅ Ownership check complete."
