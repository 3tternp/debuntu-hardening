#!/bin/bash

# Size in MB for the /home loopback file
SIZE_MB=512
LOOP_FILE="/usr/home-disk.img"
MOUNT_POINT="/mnt/home-temp"

echo "🚀 Creating a ${SIZE_MB}MB loopback file for /home at $LOOP_FILE"

sudo dd if=/dev/zero of=$LOOP_FILE bs=1M count=$SIZE_MB status=progress

echo "🖥️ Formatting $LOOP_FILE as ext4 filesystem"
sudo mkfs.ext4 $LOOP_FILE

echo "📂 Creating temporary mount point $MOUNT_POINT"
sudo mkdir -p $MOUNT_POINT

echo "🔄 Mounting loopback file to temporary mount point"
sudo mount -o loop $LOOP_FILE $MOUNT_POINT

echo "📋 Copying existing /home data to new partition"
sudo cp -a /home/. $MOUNT_POINT/

echo "🛑 Unmounting temporary mount point"
sudo umount $MOUNT_POINT

echo "📝 Backing up current /etc/fstab"
sudo cp /etc/fstab /etc/fstab.bak.$(date +%F-%T)

echo "✍️ Adding new entry to /etc/fstab for persistent mount"
echo "$LOOP_FILE /home ext4 loop,nosuid,nodev 0 0" | sudo tee -a /etc/fstab

echo "🆙 Mounting /home with new partition"
sudo mount /home

echo "✅ Done! Separate persistent partition for /home created and mounted."
