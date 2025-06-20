#!/bin/bash

# Purpose: Ensure all non-system users have existing, secure home directories

echo "🔍 Checking and creating missing home directories for valid users..."

while IFS=: read -r username _ uid _ _ homedir shell; do
    if [ "$uid" -ge 1000 ] && [[ "$shell" != "/usr/sbin/nologin" && "$shell" != "/bin/false" ]]; then
        if [ ! -d "$homedir" ]; then
            echo "⚠️  Creating missing home directory for $username at $homedir"
            mkdir -p "$homedir"
            chown "$username":"$username" "$homedir"
            chmod 700 "$homedir"
        fi
    fi
done < /etc/passwd

echo "✅ Home directory check complete."
