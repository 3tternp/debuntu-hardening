#!/bin/bash

# Fix: Ensure root user's default group is set to GID 0 (root)

set -euo pipefail

# Get current GID for root
CURRENT_GID=$(id -g root)

if [[ "$CURRENT_GID" -ne 0 ]]; then
    echo "🔧 Changing root's primary group to GID 0..."
    usermod -g 0 root
    echo "✅ Root's primary group successfully set to GID 0."
else
    echo "✅ Root's primary group is already GID 0. No changes made."
fi
