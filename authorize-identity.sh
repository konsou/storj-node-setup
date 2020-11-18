#!/bin/bash

# source THIS SCRIPT!

# exit when any command fails
set -e

# IDENTITY_DIR and IDENTITY_EXECUTABLE_DIR must be set!
if [ -z "${IDENTITY_DIR}" ]
then
    echo "IDENTITY_DIR must be set"
    exit 1
fi

if [ -z "${IDENTITY_EXECUTABLE_DIR}" ]
then
    echo "IDENTITY_EXECUTABLE_DIR must be set"
    exit 1
fi

echo
echo "Authorizing Storj identity"
echo
echo "Creating directories if needed"
mkdir -p "${IDENTITY_EXECUTABLE_DIR}"
mkdir -p "${IDENTITY_DIR}"

read -p "Enter auth token: " AUTH_TOKEN

if [ ! -e "${IDENTITY_EXECUTABLE_DIR}/identity" ]
then
    echo "Downloading identity executable"
    curl -L https://github.com/storj/storj/releases/latest/download/identity_linux_amd64.zip -o "${IDENTITY_EXECUTABLE_DIR}/identity_linux_amd64.zip"
    if [ $(dpkg-query -W -f='${Status}' unzip 2>/dev/null | grep -c "ok installed") -eq 0 ]
    then
        echo "Installing unzip"
        sudo apt update
        sudo apt -y install unzip
    fi

    unzip -o "${IDENTITY_EXECUTABLE_DIR}/identity_linux_amd64.zip" -d "${IDENTITY_EXECUTABLE_DIR}"
    chmod +x "${IDENTITY_EXECUTABLE_DIR}/identity"
fi

"${IDENTITY_EXECUTABLE_DIR}/identity authorize storagenode ${AUTH_TOKEN} --identity-dir ${IDENTITY_DIR}"
