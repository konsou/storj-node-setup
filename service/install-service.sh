#!/usr/bin/env bash

function install_service {
  service_filename=$(ls "${1}")
  echo "Installing service ${service_filename}"
  sudo cp "${service_filename}" /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable "${service_filename}"
  sudo systemctl start "${service_filename}"
}

if [ -z ${1+x} ]; then
  echo "Usage: ${0} [service_number]"
  echo "Run inside the folder where storj service files are"
  exit 1
fi

number=$1
service_filename="storagenode-${number}.service"
updater_filename="storagenode-${number}-updater.service"

if ! [ -f "${service_filename}" ] || ! [ -f "${updater_filename}" ]; then
  echo "${service_filename} and/or ${updater_filename} not found. Run this script in the folder where these files are found."
  exit 1
else
  echo "Service files found!"
fi

# exit when any command fails
set -e
# Echo commands
set -x

install_service "storagenode-${number}.service"
install_service "storagenode-${number}-updater.service"

