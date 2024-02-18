#!/bin/bash

# Promote self to root
if [ "$EUID" -ne 0 ]
	then echo "Please execute this install script as root (sudo)"
	exit
fi

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
echo "Downloading sample video"
mkdir /home/pi/videos
curl https://github.com/daklights/brcSignage/raw/master/assets/ripples.mp4 -o /home/pi/videos/ripples.mp4

echo "=== INSTALL COMPLETE ==="
echo "Installed services, video will play at next boot."
echo "To start now, run 'video start'."