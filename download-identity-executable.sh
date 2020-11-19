#!/bin/bash

# source this script!

# exit when any command fails
set -e


if [ -z "${IDENTITY_EXECUTABLE_DIR}" ]
then
    echo "IDENTITY_EXECUTABLE_DIR must be set"
    exit 1
fi

echo "Creating identity executable directory if needed"
mkdir -p "${IDENTITY_EXECUTABLE_DIR}"

if [ ! -e "${IDENTITY_EXECUTABLE_DIR}/identity" ]
then
    echo "Downloading identity executable"
    curl -L https://github.com/storj/storj/releases/latest/download/identity_linux_amd64.zip -o "${IDENTITY_EXECUTABLE_DIR}/identity_linux_amd64.zip"
    if [ $(dpkg-query -W -f='${Status}' unzip 2>/dev/null | grep -c "ok installed") -eq 0 ]
    then
        echo "Installing unzip"
        sudo apt -y install unzip
    fi

    unzip -o "${IDENTITY_EXECUTABLE_DIR}/identity_linux_amd64.zip" -d "${IDENTITY_EXECUTABLE_DIR}"
    chmod +x "${IDENTITY_EXECUTABLE_DIR}/identity"
fi
