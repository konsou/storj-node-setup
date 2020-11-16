#!/usr/bin/bash

# SETTINGS
MOUNT_DIR=/user-mounts

echo "Here are connected hard drives for this machine:"
echo
lsblk

VALID_INPUT=0
while [ "$VALID_INPUT" -eq "0" ]
do
        read -p "Type device to format for Storj (eg. sdf): " USER_INPUT
        USER_INPUT="/dev/${USER_INPUT}"
        sudo sfdisk -l "${USER_INPUT}"
        if [ $? -eq 0 ]  # command succeeded
        then
                read -p "Use this device? SELECTING Y WILL DELETE EVERYTHING ON IT! (y/n): " USER_INPUT_2
                if [[ "${USER_INPUT_2}" == "y" || "${USER_INPUT_2}" == "Y" ]]
                then
                        TARGET_DEVICE="${USER_INPUT}"
                        echo "${TARGET_DEVICE}" selected
                        VALID_INPUT=1
                fi
        else
                echo "Invalid device selection"
        fi

done

if [ -z "$TARGET_DEVICE" ]
then
    echo "Please specify the device to mount"
    exit 1
else
    echo "Using device ${TARGET_DEVICE}"
fi
