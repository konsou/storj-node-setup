#!/bin/bash
# source THIS SCRIPT!

# exit when any command fails
set -e

# MOUNT_POINT and IDENTITY_DIR must be set!
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


# Port numbers and other needed info
read -p "Enter external Storj port to use: " PORT
read -p "Enter external dashboard port to use: " DASHBOARD_PORT
read -p "Enter wallet address: " WALLET_ADDRESS
read -p "Enter email address: " EMAIL_ADDRESS
read -p "Enter external ip or web address: " WEB_ADDRESS

# CREATE NEEDED DIRS
echo "Create ${MOUNT_POINT}/storagenode"
mkdir -p "${MOUNT_POINT}/storagenode"
echo "Move identity to ${MOUNT_POINT}"
mv "${IDENTITY_DIR}" "${MOUNT_POINT}"

docker pull storjlabs/storagenode:latest

DOCKER_RUN_COMMAND='docker run -d --restart unless-stopped --stop-timeout 300 \
    -p ${PORT}:28967 \
    -p ${DASHBOARD_PORT}:14002 \
    -e WALLET="${WALLET_ADDRESS}" \
    -e EMAIL="${EMAIL_ADDRESS}" \
    -e ADDRESS="${WEB_ADDRESS}:${PORT}" \
    -e STORAGE="2TB" \
    --mount type=bind,source="<identity-dir>",destination=/app/identity \
    --mount type=bind,source="<storage-dir>",destination=/app/config \
    --name storagenode storjlabs/storagenode:latest'