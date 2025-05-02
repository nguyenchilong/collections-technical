#!/bin/bash
# Recovering Deleted Files in Linux Using lsof Command
#
# Author: Long Nguyen <nguyenchilong90@gmail.com>
# URL: https://github.com/nguyenchilong
# This script is licensed under GNU GPL version 2.0 or above
#
#

lsof +L1 | grep -i "deleted"
cp /proc/<PID>/fd/<FD_NUM> ~/recovered_file

#Find the deleted file's process ID (PID)
#and file descriptor (FD_NUM) using Isof

#Copy the file from /proc using the PID
#and file descriptor to recover your data
