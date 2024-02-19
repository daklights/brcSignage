#!/bin/bash

# Get device IP, MAC, and RESOLUTION
for iface in $(ifconfig | grep "eth0:" | cut -d ' ' -f1 | cut -d: -f1); do
     ipadd=$(ip -o -4 addr list $iface | awk '{print $4}' | cut -d/ -f1);
     madd=$(ip -o link list $iface | awk '{print $17}' | sed -e 's/://g');
done
res=$(cat /sys/class/graphics/fb0/virtual_size)

# Get the phone home config file
phoneHomeIP=$(cat /home/pi/phoneHomeConfig.txt)

# Get current video
fullVideo=`ls /home/pi/videos/*.mp4`
currentVideo=$(basename $fullVideo)

# Make phone home checkin
fullArgs="?m=${madd}&i=${ipadd}&r=${res}&v=${currentVideo}"
fullURL="http://${phoneHomeIP}/remoteCheckin.php${fullArgs}"
jsonData=$(curl -s "${fullURL}")

# Split response variables
IFS='|' read -r -a responseArray <<< "${jsonData}"

m=${responseArray[0]}
v=${responseArray[1]}

# Check for call/response match
if [ "$madd" == "$m" ]; then
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