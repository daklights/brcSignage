#!/bin/bash

# Ensure this script is run as root
if [ "$(id -u)" -ne 0 ]; then echo "Please run this install script as root." >&2; exit 1; fi

# Start install process
echo $(date) ": === STARTING INSTALL ==="

# Install deps
echo $(date) ": Updating system"
apt update

echo $(date) ": Installing/Updating curl, vlc, and cec-utils"
apt install -y curl vlc cec-utils

# Install/uninstall scripts
echo $(date) ": Downloading video scripts"
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/player.sh -o /opt/player.sh
chmod +x /opt/player.sh
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/ping.sh -o /opt/ping.sh
chmod +x /opt/ping.sh
cronjob="* * * * * /opt/ping.sh >> /var/log/brcSignagePing_`date +\%Y\%m\%d`.log"
(crontab -u root -l; echo "$cronjob" ) | crontab -u root -
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/logCleanup.sh -o /opt/logCleanup.sh
chmod +x /opt/logCleanup.sh
cronjob="0 4 * * * /opt/logCleanup.sh >> /var/log/brcSignagePing_`date +\%Y\%m\%d`.log"
(crontab -u root -l; echo "$cronjob" ) | crontab -u root -
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/video -o /usr/local/bin/video
chmod +x /usr/local/bin/video
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/phoneHomeConfig.txt -o /home/pi/phoneHomeConfig.txt

# Install systemd unit
echo $(date) ": Downloading video service"
curl -s https://raw.githubusercontent.com/daklights/brcSignage/master/src/video.service -o /etc/systemd/system/video.service
systemctl enable video.service

# Create the videos directory and download sample video
echo $(date) ": Creating videos directory"
mkdir /home/pi/videos

# Complete install process
echo $(date) "=== INSTALL COMPLETE ==="
echo $(date) ": Service installation successful; video playback will automatically begin after you setup the phoneHome configuration."
echo $(date) ": REMINDER: adjust your phoneHomeConfig.txt file as instructed in the /home/pi/phoneHomeConfig.txt sample file!"