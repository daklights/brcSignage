#!/bin/bash

# Get device eth0 IP and MAC address
ETHI=$(/sbin/ifconfig | grep -E "eth0:" | cut -d ' ' -f1 | cut -d: -f1)
ETHI_i=$(ip -o -4 addr list $ETHI | awk '{print $4}' | cut -d/ -f1);
ETHI_m=$(ip -o link list $ETHI | awk '{print $17}' | sed -e 's/://g');

# Get device wlan0 IP and MAC address
WLAI=$(/sbin/ifconfig | grep -E "wlan0:" | cut -d ' ' -f1 | cut -d: -f1)
WLAI_i=$(ip -o -4 addr list $WLAI | awk '{print $4}' | cut -d/ -f1);
WLAI_m=$(ip -o link list $WLAI | awk '{print $17}' | sed -e 's/://g');

# Get device screen resoltuion
res=$(cat /sys/class/graphics/fb0/virtual_size)

# Get the phone home config file
phoneHomeIP=$(cat /home/pi/phoneHomeConfig.txt)

# Get current video
fullVideo=`ls /home/pi/videos/*.mp4`
currentVideo=$(basename $fullVideo)

# Make phone home checkin
fullArgs="?em=${ETHI_m}&ei=${ETHI_i}&wm=${WLAI_m}&wi=${WLAI_i}&r=${res}&v=${currentVideo}"
fullURL="http://${phoneHomeIP}/remoteCheckin.php${fullArgs}"
jsonData=$(curl -s "${fullURL}")

# Split response variables
IFS='|' read -r -a responseArray <<< "${jsonData}"
em=${responseArray[0]}
wm=${responseArray[1]}
v=${responseArray[2]}

# Check for call/response match (on any mac address)
if [ "$ETHI_m" == "$em" ] || [ "$WLAI_m" == "$wm" ]; then
	# Call/response match, continue processing
	if [ "$currentVideo" != "$v" ]; then
			# Video has changed, clear existing video, then download new one, then restart video service
			echo $(date -u) ": Removing existing MP4 video (${currentVideo})"
			rm /home/pi/videos/*.mp4
			echo $(date -u) ": Downloading new MP4 video (${v})"
			curl -s "http://${phoneHomeIP}/videos/${v}" -o /home/pi/videos/${v}
			echo $(date -u) ": Restarting video service"
			systemctl restart video.service
			echo $(date -u) ": Video update complete"
	fi
else
	# Call/response do not match
	echo $(date -u) ": Call/response mismatch; no action taken"
fi