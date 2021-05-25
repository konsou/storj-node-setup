#!/bin/bash
# RUN THIS SCRIPT AS A NORMAL USER
# WILL SUDO WHEN NEEDED

# find_python function copied from chia-blockchain
# https://github.com/Chia-Network/chia-blockchain
# Copyright 2021 Chia Network
# License https://github.com/Chia-Network/chia-blockchain/blob/main/LICENSE
find_python() {
        set +e
        unset BEST_PYTHON_VERSION
        for V in 3.9 39 3.8 38; do
                if which python$V >/dev/null; then
                        if [ x"$BEST_PYTHON_VERSION" = x ]; then
                                BEST_PYTHON_VERSION=$V
                        fi
                fi
        done
        # echo $BEST_PYTHON_VERSION
        set -e
}

set -e

while true; do
  find_python
  if [[ -z "$BEST_PYTHON_VERSION" ]]; then
    echo "No valid Python 3 found - version >= 3.8 required."
     while true; do
       read -p "Install Python 3.9 from deadsnakes PPA? (Y/n): " USER_INPUT
       if [[ "${USER_INPUT}" == "y" || "${USER_INPUT}" == "Y" || "${USER_INPUT}" == "" ]]; then
         sudo add-apt-repository ppa:deadsnakes/ppa
         sudo apt update
         sudo apt install python3.9 -y
         break
       else
         echo "Please install Python 3.8 or newer manually to continue."
         exit 1
       fi
     done

  else
    echo "Using Python ${BEST_PYTHON_VERSION}"
    PYTHON_EXECUTABLE=python${BEST_PYTHON_VERSION}
    break
  fi
done


# Start the Python main script
"${PYTHON_EXECUTABLE}" ./python_scripts/main.py


