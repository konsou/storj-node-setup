#!/bin/bash
# RUN THIS SCRIPT AS A NORMAL USER
# WILL SUDO WHEN NEEDED

sudo apt update


# find_python function copied from chia-blockchain
# https://github.com/Chia-Network/chia-blockchain
# Copyright 2021 Chia Network
# License https://github.com/Chia-Network/chia-blockchain/blob/main/LICENSE
find_python() {
        set +e
        unset BEST_PYTHON_VERSION
        for V in 3.9 39 3.8 38 3.7 37; do
                if which python$V >/dev/null; then
                        if [ x"$BEST_PYTHON_VERSION" = x ]; then
                                BEST_PYTHON_VERSION=$V
                        fi
                fi
        done
        # echo $BEST_PYTHON_VERSION
        set -e
}

ask_manual_python_install_and_exit() {
  echo "Please install Python 3.7 or newer and python3-pip manually to continue."
  exit 1
}

set -e

while true; do
  find_python
  if [[ -z "$BEST_PYTHON_VERSION" ]]; then
    echo "No valid Python 3 found - version >= 3.7 required."
     while true; do
       read -r -p "Install Python 3.9 from deadsnakes PPA? (Y/n): " USER_INPUT
       if [[ "${USER_INPUT}" == "y" || "${USER_INPUT}" == "Y" || "${USER_INPUT}" == "" ]]; then
         set +e
         sudo apt install software-properties-common -y
         if ! sudo add-apt-repository ppa:deadsnakes/ppa; then
           ask_manual_python_install_and_exit
         fi
         if ! sudo apt update; then
           ask_manual_python_install_and_exit
         fi
         if ! sudo apt install python3.9 -y; then
           ask_manual_python_install_and_exit
         fi
         set -e
         break
       else  # user selected "no" for automatic Python install
         ask_manual_python_install_and_exit
       fi
     done

  else
    echo "Using Python ${BEST_PYTHON_VERSION}"
    PYTHON_EXECUTABLE=python${BEST_PYTHON_VERSION}
    break
  fi
done

# TODO: Check if install is needed
read -r -p "Install prerequisite packages? (python3-pip) (Y/n): " USER_INPUT
if [[ "${USER_INPUT}" == "y" || "${USER_INPUT}" == "Y" || "${USER_INPUT}" == "" ]]; then
  sudo apt install python3-pip -y
else
  ask_manual_python_install_and_exit
fi

# Install required python packages
pip3 install -r requirements.txt

# Start the Python main script
"${PYTHON_EXECUTABLE}" ./python_scripts/main.py


