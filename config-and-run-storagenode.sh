#!/bin/bash
# source THIS SCRIPT!

# exit when any command fails
set -e

# MOUNT_POINT, IDENTITY_DIR and NODE_NAME must be set!
if [ -z "${MOUNT_POINT}" ]
then
    echo "MOUNT_POINT must be set"
    exit 1
fi

if [ -z "${IDENTITY_DIR}" ]  # directory where the signed identity is
then
    echo "IDENTITY_DIR must be set"
    exit 1
fi

if [ -z "${NODE_NAME}" ]
then
    echo "NODE_NAME must be set"
    exit 1
fi

# Node space calculation script is in Python
if [ $(dpkg-query -W -f='${Status}' python3 2>/dev/null | grep -c "ok installed") -eq 0 ]
then
    echo "Installing python3"
    sudo apt update
    sudo apt -y install python3
fi


# Port numbers and other needed info
read -p "Enter external Storj port to use (default is 28967): " PORT
read -p "Enter external dashboard port to use (default is 14002): " DASHBOARD_PORT
read -p "Enter wallet address: " WALLET_ADDRESS
read -p "Enter email address: " EMAIL_ADDRESS
read -p "Enter external ip or web address: " WEB_ADDRESS

TOTAL_SPACE=$(df ${MOUNT_POINT} --output='avail' --block-size=TB | grep 'TB')
AVAILABLE_SPACE=$(./calculate-node-space.py "${TOTAL_SPACE}")

# CREATE NEEDED DIRS
# UNCOMMENT THESE!!
echo "Create ${MOUNT_POINT}/storagenode"
# mkdir -p "${MOUNT_POINT}/storagenode"
echo "Move identity to ${MOUNT_POINT}"
# mv "${IDENTITY_DIR}" "${MOUNT_POINT}"

docker pull storjlabs/storagenode:latest

DOCKER_RUN_COMMAND="docker run -d --restart unless-stopped --stop-timeout 300 \
    -p ${PORT}:28967 \
    -p ${DASHBOARD_PORT}:14002 \
    -e WALLET="${WALLET_ADDRESS}" \
    -e EMAIL="${EMAIL_ADDRESS}" \
    -e ADDRESS="${WEB_ADDRESS}:${PORT}" \
    -e STORAGE="${AVAILABLE_SPACE}" \
    --mount type=bind,source="${MOUNT_POINT}/identity",destination=/app/identity \
    --mount type=bind,source="${MOUNT_POINT}/storagenode",destination=/app/config \
    --name "storagenode-${NODE_NAME}" storjlabs/storagenode:latest"

echo "${DOCKER_RUN_COMMAND}"