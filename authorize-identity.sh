#!/bin/bash

# source this script!

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
mkdir -p "${IDENTITY_DIR}"

read -p "Enter auth token: " AUTH_TOKEN

source ./download-identity-executable.sh

"${IDENTITY_EXECUTABLE_DIR}/identity" authorize storagenode "${AUTH_TOKEN}" --identity-dir "${IDENTITY_DIR}"
