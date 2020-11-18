#!/bin/bash

# exit when any command fails
set -e

echo
echo "Generating Storj identity"
echo
mkdir -p ./identity-executable
curl -L https://github.com/storj/storj/releases/latest/download/identity_linux_amd64.zip -o ./identity-executable/identity_linux_amd64.zip
sudo apt update
sudo apt -y install unzip
unzip -o ./identity-executable/identity_linux_amd64.zip -d ./identity-executable
chmod +x ./identity-executable/identity

mkdir -p ./identity
./identity-executable/identity create storagenode --identity-dir ./identity
