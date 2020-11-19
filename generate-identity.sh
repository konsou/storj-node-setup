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
echo "Generating Storj identity"
echo "THIS WILL TAKE SOME TIME DEPENDING ON YOUR CPU POWER"
echo
echo "Creating directories if needed"
mkdir -p "${IDENTITY_DIR}"

source ./download-identity-executable.sh

"${IDENTITY_EXECUTABLE_DIR}/identity" create storagenode --identity-dir "${IDENTITY_DIR}"
