#!/usr/bin/bash

# SETTINGS
MOUNT_DIR_BASE=/user-mounts

# SELECT DEVICE
VALID_INPUT=0
while [ "$VALID_INPUT" -eq "0" ]
do
        echo
        echo "Here are the connected hard drives for this machine:"
        echo
        lsblk
        echo
        read -p "Type device to format for Storj (eg. sdf): " USER_INPUT
        echo
        USER_INPUT="/dev/${USER_INPUT}"
        sudo sfdisk -l "${USER_INPUT}"
        if [ $? -eq 0 ]  # command succeeded
        then
                echo
                read -p "Use this device? SELECTING Y WILL DELETE EVERYTHING ON IT! (y/n): " USER_INPUT_2
                if [[ "${USER_INPUT_2}" == "y" || "${USER_INPUT_2}" == "Y" ]]
                then
                        TARGET_DEVICE="${USER_INPUT}"
                        TARGET_PARTITION="${TARGET_DEVICE}1"
                        echo "Device ${TARGET_DEVICE}" selected
                        echo "Partition ${TARGET_PARTITION}" selected
                        VALID_INPUT=1
                fi
        else
                echo "Invalid device selection"
        fi

done

# MODIFY FILESYSTEM
echo
# sudo sfdisk --delete "${TARGET_DEVICE}" --backup
sudo wipefs --all --force "${TARGET_DEVICE}"
if [ $? -ne 0 ]; then exit 2; fi
echo
echo "type=83" | sudo sfdisk "${TARGET_DEVICE}"  # create linux type partition
if [ $? -ne 0 ]; then exit 2; fi
echo
sudo mkfs.ext4 -F "${TARGET_PARTITION}"
if [ $? -ne 0 ]; then exit 2; fi
echo
TARGET_PARTITION_UUID=$(sudo blkid -o value -s UUID /dev/sdb1)
echo "UUID for created partition is ${TARGET_PARTITION_UUID}"
echo

# GENERATE NODE NAME FROM DRIVE VENDOR AND SN
HDD_VENDOR=$(./get-vendor.sh "${TARGET_DEVICE}")
HDD_SERIAL_LAST_4=$(./get-serial-last-4.sh  "${TARGET_DEVICE}")
NODE_NAME="${HDD_VENDOR}-${HDD_SERIAL_LAST_4}"
echo "Node name is ${NODE_NAME}"
MOUNT_POINT="${MOUNT_DIR_BASE}/${NODE_NAME}"
echo "Mount point is ${MOUNT_POINT}"
