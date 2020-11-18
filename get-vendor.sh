#!/bin/bash
MODEL_LINE=$(sudo fdisk -l "$1" | grep "Disk model:")
read -ra SPLIT <<<"${MODEL_LINE}"
VENDOR="${SPLIT[2]}"
echo "${VENDOR}" | tr '[:upper:]' '[:lower:]'  # to lower case