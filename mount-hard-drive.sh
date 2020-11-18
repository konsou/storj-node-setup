#!/bin/bash
# RUN THIS SCRIPT AS A NORMAL USER
# WILL SUDO WHEN NEEDED

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

# exit when any command fails
set -e

# MODIFY FILESYSTEM
echo
 ls "${TARGET_DEVICE}"* | sudo xargs -n1 umount -l  # umount all partitions of the device
# sudo sfdisk --delete "${TARGET_DEVICE}" --backup
sudo wipefs --all --force "${TARGET_DEVICE}"
echo
echo "type=83" | sudo sfdisk "${TARGET_DEVICE}"  # create linux type partition
echo
sudo mkfs.ext4 -F "${TARGET_PARTITION}"
echo
TARGET_PARTITION_UUID=$(sudo blkid -o value -s UUID "${TARGET_PARTITION}")
echo "UUID for created partition is ${TARGET_PARTITION_UUID}"
echo

# GENERATE NODE NAME FROM DRIVE VENDOR AND SN
HDD_VENDOR=$(./get-vendor.sh "${TARGET_DEVICE}")
HDD_SERIAL_LAST_4=$(./get-serial-last-4.sh  "${TARGET_DEVICE}")
NODE_NAME="${HDD_VENDOR}-${HDD_SERIAL_LAST_4}"
echo "Node name is ${NODE_NAME}"
MOUNT_POINT="${MOUNT_DIR_BASE}/${NODE_NAME}"
echo "Mount point is ${MOUNT_POINT}"
sudo e2label "${TARGET_PARTITION}" "${NODE_NAME}"

# MOUNTING
echo "Creating mount point"
sudo mkdir -p "${MOUNT_POINT}"
echo "Test mount"
sudo mount -U "${TARGET_PARTITION_UUID}" "${MOUNT_POINT}"
echo "Set owner to ${USER}:$(id -gn)"
sudo chown -R "${USER}:$(id -gn)" "${MOUNT_POINT}"
echo "Test file write"
echo "test" > "${MOUNT_POINT}/test.txt"
echo "Remove test file"
rm "${MOUNT_POINT}/test.txt"
echo "Unmount"
sudo umount "${MOUNT_POINT}"
# Remove reserved space (unneeded for data partition)
sudo tune2fs -m 0 "${TARGET_PARTITION}"
echo "Write fstab"
# Use tee --append - "echo >> file" doesn't work with sudo rights!
# no output needed (file contents) -> redirecto to /dev/null
echo "UUID=${TARGET_PARTITION_UUID} ${MOUNT_POINT} ext4 nosuid,nodev,nofail,x-gvfs-show  0  2" | sudo tee --append /etc/fstab > /dev/null
sudo mount -av

