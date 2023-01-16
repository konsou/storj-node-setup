#!/usr/bin/env bash

# Echo commands
set -x

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
  exit 1
fi

number=$1
install_service "storagenode-${number}.service"
install_service "storagenode-${number}-updater.service"

