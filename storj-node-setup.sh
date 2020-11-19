#!/bin/bash
# RUN THIS SCRIPT AS A NORMAL USER
# WILL SUDO WHEN NEEDED

# SETTINGS
MOUNT_DIR_BASE=/user-mounts
IDENTITY_EXECUTABLE_DIR=./identity-executable
IDENTITY_DIR=./identity

CURRENT_IPS=$(hostname -I)

echo "BEFORE YOU BEGIN"
echo
echo "Identity - you need one of these:"
echo "  -an auth token from https://registration.storj.io/ OR"
echo "  -an authorized identity"
echo
echo "-your server must have a static IP set (current IPs: ${CURRENT_IPS})"
echo "-Storj port must have been opened and redirected to this machine in the router"
echo
echo "It's not a good idea to generate an identity on a Raspberry Pi or"
echo "other hardware that's not powerful because it will take forever."
echo "It's better to generate an identity on your main computer."
echo "Identity generation guide: https://documentation.storj.io/dependencies/identity"
echo
read -p "Generate identity now? (y/n): " USER_INPUT
if [[ "${USER_INPUT}" == "y" || "${USER_INPUT}" == "Y" ]]
then
        source ./generate-identity.sh
else
        read -p "Enter identity directory path: " IDENTITY_DIR
fi

echo "Using identity directory ${IDENTITY_DIR}"

# Authorize identity here
echo "Do we need to authorize the identity?"
echo "AUTHORIZED IDENTITY IS REQUIRED, ONLY SELECT NO"
echo "IF YOU'VE AUTHORIZED THE IDENTITY BEFOREHAND"
read -p  "(y/n): " USER_INPUT
if [[ "${USER_INPUT}" == "y" || "${USER_INPUT}" == "Y" ]]
then
        source ./authorize-identity.sh
else
        echo "Skipping identity authorization"
fi

# SELECT DEVICE
VALID_INPUT=0
while [ "$VALID_INPUT" -eq "0" ]
do
        echo
        echo "Here are the connected hard drives for this machine:"
        echo
        sudo lsblk -o name,size,type,label,mountpoint
        echo
        read -p "Type device to format for Storj (eg. sdf): " USER_INPUT
        echo
        USER_INPUT="/dev/${USER_INPUT}"
        sudo sfdisk -l "${USER_INPUT}"
        echo
        sudo lsblk -o name,size,type,label,mountpoint "${USER_INPUT}"
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

# TARGET_DEVICE and TARGET_PARTITION must be set for this script
# This script sets TARGET_PARTITION_UUID variable
source ./partition-and-format-disk.sh "${TARGET_DEVICE}" "${TARGET_PARTITION}"
if [ -z "${TARGET_PARTITION_UUID}" ]
then
    echo "Didn't get TARGET_PARTITION_UUID from partition-and-format-disk.sh"
    exit 1
fi


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
echo "Write mount settings to fstab for automatic mounting on startup"
# Use tee --append - "echo >> file" doesn't work with sudo rights!
# no output needed (file contents) -> redirecto to /dev/null
echo "UUID=${TARGET_PARTITION_UUID} ${MOUNT_POINT} ext4 nosuid,nodev,nofail,x-gvfs-show  0  2" | sudo tee --append /etc/fstab > /dev/null
echo "Reload fstab settings"
sudo mount -av

# INSTALL DOCKER
./install-docker.sh

# CONFIG AND RUN STORAGENODE
source ./config-and-run-storagenode.sh

echo 
echo "NODE SETUP COMPLETE!"
echo
echo "Final steps:"
echo "    -check that the web dashboard works and that the node is online"
echo "    -set up monitoring at eg. uptimerobot.com"
echo




