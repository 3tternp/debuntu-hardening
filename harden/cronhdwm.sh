#!/bin/bash

# Secure cron directories
for dir in /etc/cron.{hourly,daily,weekly,monthly}; do
  if [ -d "$dir" ]; then
    chmod 0700 "$dir"
    chown root:root "$dir"
    echo "✅ Fixed: $dir"
    ls -ld "$dir"
  else
    echo "❌ Missing directory: $dir"
  fi
done
