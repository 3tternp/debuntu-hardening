#!/bin/bash

# Restrict at/cron usage to authorized users

echo "root" | tee /etc/at.allow /etc/cron.allow > /dev/null

chmod 0600 /etc/at.allow /etc/cron.allow
chown root:root /etc/at.allow /etc/cron.allow

# Remove deny files if they exist
[ -f /etc/at.deny ] && rm -f /etc/at.deny
[ -f /etc/cron.deny ] && rm -f /etc/cron.deny

echo "✅ Restricted at/cron access to root only."
ls -l /etc/at.allow /etc/cron.allow
