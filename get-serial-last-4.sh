#!/bin/bash
SERIAL=$(udevadm info --query=all --name="$1" | grep ID_SERIAL_SHORT)
echo "${SERIAL: -4}" | tr '[:upper:]' '[:lower:]'  # to lower case