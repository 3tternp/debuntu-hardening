#!/bin/bash

# Fix: Set default user shell timeout to 900 seconds or less

TIMEOUT_FILE="/etc/profile.d/99-shell-timeout.sh"

# Create or overwrite timeout policy
cat <<EOF | sudo tee "$TIMEOUT_FILE" > /dev/null
# Enforce session timeout for all users
export TMOUT=900
readonly TMOUT
export HISTCONTROL=ignoreboth
EOF

echo "✅ Default shell timeout set to 900 seconds in $TIMEOUT_FILE"
