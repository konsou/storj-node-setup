!#/usr/bin/bash

# SETTINGS
MOUNT_DIR=/user-mounts
TARGET_DEVICE="$1"

if [ -z "$TARGET_DEVICE" ]
then
    echo "Please specify the device to mount"
    exit 1
fi
