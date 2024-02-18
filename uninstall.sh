#!/bin/bash

# Promote self to root
if [ "$EUID" -ne 0 ]
	then echo "Please execute this uninstall script as root (sudo)"
	exit
fi

# Stop service
echo "Stopping video service"
systemctl stop video.service

# Remove systemd unit
echo "Removing video service"
systemctl disable video.service

# Remove scripts
echo "Removing video scripts"
rm -f /opt/player.sh
rm -f /usr/local/bin/video

echo "=== UNINSTALL COMPLETE ==="