#!/bin/bash

# start CVLC video
/usr/bin/cvlc --fullscreen --no-audio --loop --no-video-title-show /home/pi/videos/*.mp4

# turn on TV (if supported)
echo "on 0.0.0.0" | cec-client -s -d 1

# set TV to this input (if supported)
echo "as 0.0.0.0" | cec-client -s -d 1