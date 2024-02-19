#!/bin/bash

# Get device eth0 IP and MAC address
ETHI=$(/sbin/ifconfig | grep -E "eth0:" | cut -d ' ' -f1 | cut -d: -f1)
ETHI_i=$(ip -o -4 addr list $ETHI | awk '{print $4}' | cut -d/ -f1);
ETHI_m=$(ip -o link list $ETHI | awk '{print $17}' | sed -e 's/://g');

# Get device wlan0 IP and MAC address
WLAI=$(/sbin/ifconfig | grep -E "wlan0:" | cut -d ' ' -f1 | cut -d: -f1)
WLAI_i=$(ip -o -4 addr list $WLAI | awk '{print $4}' | cut -d/ -f1);
WLAI_m=$(ip -o link list $WLAI | awk '{print $17}' | sed -e 's/://g');

# Get device hostname
hn=$(cat /etc/hostname)

# Get device screen resoltuion
res=$(cat /sys/class/graphics/fb0/virtual_size | tr ',' 'x')

# Get current video
fullVideo=`ls /home/pi/videos/*.mp4`
currentVideo=$(basename $fullVideo)

# Get current power status
curPow=$(echo "pow 0.0.0.0" | cec-client -s -d 1 | grep power)
curPow=${curPow//"power status: "/}

# Make remote checkin call
fullArgs="?em=${ETHI_m}&ei=${ETHI_i}&wm=${WLAI_m}&wi=${WLAI_i}&hn=${hn}&cp=${curPow}&r=${res}&v=${currentVideo}"
while IFS= read -r line; do
	fullURL="http://${line}/remoteCheckin.php${fullArgs}"
	response=$(curl -s -w "\n%{http_code}" $fullURL)
	http_code=$(tail -n1 <<< "$response")
	jsonData=$(sed '$ d' <<< "$response")
	if [ "$http_code" == "200" ]; then
		phoneHomeIP=$line
		break;
	else
		echo $(date -u) ": Invalid response detected from phoneHome configuration entry [$line] [HTTP:$http_code]"
		echo $(date -u) ": You should set a new phoneHome configuration entry if this error happens often"
	fi
done < /home/pi/phoneHomeConfig.txt

# Split response variables
IFS='|' read -r -a responseArray <<< "${jsonData}"
em=${responseArray[0]}
wm=${responseArray[1]}
c=${responseArray[2]}
v=${responseArray[3]}

# Check for call/response match (on any mac address)
if [ "$ETHI_m" == "$em" ] || [ "$WLAI_m" == "$wm" ]; then
	# Call/response match, continue processing
	
	# Do command execution (if needed)
	if [ "$c" != "NOTHING" ]; then
		if [ "$c" == "POWERON" ]; then
			echo $(date -u) ": Turning power on and setting active input"
			echo "on 0.0.0.0" | cec-client -s -d 1
			echo "as 0.0.0.0" | cec-client -s -d 1
		elif [ "$c" == "POWEROFF" ]; then
			echo $(date -u) ": Turning power off"
			echo "standby 0.0.0.0" | cec-client -s -d 1
		elif [ "$c" == "REBOOT" ]; then
			echo $(date -u) ": Rebooting device"
			/sbin/reboot
		fi	
	fi
	
	# Do video swap (if needed)
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
	echo $(date -u) ": Sent [$fullURL]"
	echo $(date -u) ": Received [$em] [$wm] [$c] [$v]"
	
fi