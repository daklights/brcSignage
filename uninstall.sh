#!/bin/bash

# Ensure this script is run as root
if [ "$(id -u)" -ne 0 ]; then echo "Please run this uninstall script as root." >&2; exit 1; fi

# Start uninstall process
echo $(date) ": === STARTING UNINSTALL ==="

# Stop service
echo $(date) ": Stopping video service"
systemctl stop video.service

# Remove systemd unit
echo $(date) ": Removing video service"
systemctl disable video.service

# Remove scripts
echo $(date) ": Removing video scripts"
rm -f /opt/player.sh
rm -f /opt/ping.sh
rm -f /usr/local/bin/video
rm -f /home/pi/phoneHomeConfig.txt

# Set reminder for user to clean up crontab
echo $(date) ": WARNING: you must manually remove the crontab entry for ping.sh (sudo crontab -e)"

# Complete uninstall process
echo $(date) ": === UNINSTALL COMPLETE ==="