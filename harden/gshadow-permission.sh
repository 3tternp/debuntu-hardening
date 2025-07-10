#!/bin/bash

# Fix: Secure /etc/gshadow permissions and ownership

set -e

FILE="/etc/gshadow"

if [ -f "$FILE" ]; then
    echo "🔧 Securing $FILE..."
    sudo chown root:shadow "$FILE"
    sudo chmod 640 "$FILE"
    echo "✅ $FILE permissions set to 640 and ownership set to root:shadow"
else
    echo "❌ $FILE does not exist."
fi
