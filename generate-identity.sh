#!/bin/bash

# exit when any command fails
set -e

IDENTITY_EXECUTABLE_DIR=./identity-executable
IDENTITY_DIR=./identity

echo
echo "Generating Storj identity"
echo
echo "Creating directories if needed"
mkdir -p "${IDENTITY_EXECUTABLE_DIR}"
mkdir -p "${IDENTITY_DIR}"

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

"${IDENTITY_EXECUTABLE_DIR}/identity" create storagenode --identity-dir "${IDENTITY_DIR}"
