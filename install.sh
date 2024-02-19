#!/bin/bash

# Ensure this script is run as root
if [ "$(id -u)" -ne 0 ]; then echo "Please run this install script as root." >&2; exit 1; fi

# Start install process
echo $(date -u) ": === STARTING INSTALL ==="

# Install deps
echo $(date -u) ": Updating system"
apt update

echo $(date -u) ": Installing/Updating curl, vlc, and cec-utils"
apt install -y curl vlc cec-utils

# Install/uninstall scripts
echo $(date -u) ": Downloading video scripts"
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/player.sh -o /opt/player.sh
chmod +x /opt/player.sh
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/ping.sh -o /opt/ping.sh
chmod +x /opt/ping.sh
cronjob="* * * * * /opt/ping.sh > /var/log/brcSignage_ping.log"
(crontab -u userhere -l; echo "$cronjob" ) | crontab -u userhere -
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/video -o /usr/local/bin/video
chmod +x /usr/local/bin/video
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/uninstall.sh -o /home/pi/uninstall.sh
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/phoneHomeConfig.txt -o /home/pi/phoneHomeConfig.txt

# Install systemd unit
echo $(date -u) ": Downloading video service"
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/video.service -o /etc/systemd/system/video.service
systemctl enable video.service

# Create the videos directory and download sample video
echo $(date -u) ": Creating videos directory"
mkdir /home/pi/videos
echo $(date -u) ": REMINDER: adjust your phoneHomeConfig.txt file as instructed in the /home/pi/phoneHomeConfig.txt sample file!"

# Complete install process
echo $(date -u) "=== INSTALL COMPLETE ==="
echo $(date -u) "Installed services, video will play at next boot."
echo $(date -u) "To start now, run 'video start'."