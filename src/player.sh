#!/bin/bash

# turn on TV
#echo "on 0.0.0.0" | cec-client -s -d 1

# set TV to this input
#echo "as 0.0.0.0" | cec-client -s -d 1

# start CVLC video
/usr/bin/cvlc --fullscreen --no-audio --loop --no-video-title-show /home/pi/videos/ripples.mp4