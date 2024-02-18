#!/bin/bash

# Ensure this script is run as root
if [ "$(id -u)" -ne 0 ]; then echo "Please run this install script as root." >&2; exit 1; fi

# Install deps
echo "Updating system"
apt update

echo "Installing/Updating curl, vlc, and cec-utils"
apt install -y curl vlc cec-utils

# Install/uninstall scripts
echo "Downloading video scripts"
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/player.sh -o /opt/player.sh
chmod +x /opt/player.sh
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/video -o /usr/local/bin/video
chmod +x /usr/local/bin/video
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/uninstall.sh -o /home/pi/uninstall.sh

# Install systemd unit
echo "Downloading video service"
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/video.service -o /etc/systemd/system/video.service
systemctl enable video.service

# Create the videos directory and download sample video
mkdir /home/pi/videos
echo "REMINDER: download videos into the /home/pi/videos folder before starting the video service!"

echo "=== INSTALL COMPLETE ==="
echo "Installed services, video will play at next boot."
echo "To start now, run 'video start'."