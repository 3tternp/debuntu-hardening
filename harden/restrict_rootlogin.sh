#!/bin/bash

# Fix: Restrict root login to system consoles by setting /etc/securetty

SECURETTY_FILE="/etc/securetty"

cat <<EOF | sudo tee "$SECURETTY_FILE" > /dev/null
console
vc/1
vc/2
vc/3
vc/4
tty1
EOF

echo "✅ Root login is now restricted to listed system consoles only in $SECURETTY_FILE."
