#!/bin/bash

# Ensure this script is run as root
if [ "$(id -u)" -ne 0 ]; then echo "Please run this uninstall script as root." >&2; exit 1; fi

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