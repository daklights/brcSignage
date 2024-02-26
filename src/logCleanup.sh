#!/bin/bash

# cleanup log files
echo $(date) ": Cleaning up log files"
find /var/log/brc*.log -mtime +14 -type f -delete