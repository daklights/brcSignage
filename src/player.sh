#!/bin/bash

# turn on TV
echo "on 0.0.0.0" | cec-client -s -d 1
sleep 5

# set TV to this input
echo "as 0.0.0.0" | cec-client -s -d 1
sleep 5

# start CVLC video
/usr/bin/cvlc --fullscreen --no-audio --repeat --no-video-title-show /home/pi/ripples.mp4