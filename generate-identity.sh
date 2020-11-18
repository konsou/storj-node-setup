#!/bin/bash

# exit when any command fails
set -e

echo
echo "Generating Storj identity"
echo
curl -L https://github.com/storj/storj/releases/latest/download/identity_linux_amd64.zip -o identity_linux_amd64.zip
sudo apt update
sudp apt install unzip
unzip -o identity_linux_amd64.zip
chmod +x ./identity

./identity create storagenode --identity-dir ./identity
