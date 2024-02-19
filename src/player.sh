#!/bin/bash

# Start CVLC video
echo $(date -u) ": Starting CVLC player"
/usr/bin/cvlc --fullscreen --no-audio --loop --no-video-title-show /home/pi/videos/*.mp4