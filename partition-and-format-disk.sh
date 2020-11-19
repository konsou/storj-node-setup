#!/bin/bash

# source THIS SCRIPT!


# TARGET_DEVICE=$1
# TARGET_PARTITION=$2

# TARGET_DEVICE and TARGET_PARTITION must be set!
if [ -z "${TARGET_DEVICE}" ]
then
    echo "TARGET_DEVICE must be set"
    exit 1
fi

if [ -z "${TARGET_PARTITION}" ]
then
    echo "TARGET_PARTITION must be set"
    exit 1
fi

# THIS SCRIPT SETS TARGET_PARTITION_UUID VARIABLE

# exit when any command fails
set -e

# PARTITION AND FORMAT THE DISK
echo
echo "PARTITION AND FORMAT ${TARGET_DEVICE}"
echo
echo "Unmount all partitions of the device (if currently mounted)"
echo
# || true -> don't exit if this fails (partition not mounted)
ls "${TARGET_DEVICE}"* | sudo xargs -n1 umount -l || true  
echo
echo "Delete current partitions"
echo
sudo wipefs --all --force "${TARGET_DEVICE}"
echo
echo "Create a new partition"
echo
echo "type=83" | sudo sfdisk "${TARGET_DEVICE}"  # create linux type partition
echo
echo "Format the new partition"
echo
sudo mkfs.ext4 -F "${TARGET_PARTITION}"
# Remove reserved space (unneeded for data partition)
sudo tune2fs -m 0 "${TARGET_PARTITION}"
echo
TARGET_PARTITION_UUID=$(sudo blkid -o value -s UUID "${TARGET_PARTITION}")
echo "UUID for created partition is ${TARGET_PARTITION_UUID}"
echo

