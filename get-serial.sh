#!/usr/bin/bash
SERIAL=$(udevadm info --query=all --name=/dev/sdd | grep ID_SERIAL_SHORT)
echo "${SERIAL}" | tr '[:upper:]' '[:lower:]'  # to lower case