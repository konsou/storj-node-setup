#!/usr/bin/bash

# exit when any command fails
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

echo 
echo "INSTALLING DOCKER"
echo

echo "Install prerequisites"
echo
sudo apt update

sudo apt -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

echo
echo "Add Docker key"
echo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

echo 
echo "Add docker repo. THIS MAY FAIL ON MINT, FIX"
echo
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo
echo "Install docker packages"
echo
sudo apt update
sudo apt -y install docker-ce docker-ce-cli containerd.io

echo
echo "Test docker as root"
echo
# Test #1 - as root
sudo docker run hello-world

echo
echo "Add ${USER} to docker group"
echo
sudo groupadd docker || true # don't exit if this fails (group may already exist)
sudo usermod -aG docker $USER

newgrp docker
echo
echo "Test docker as regular user"
echo
# Test #2 - as a regular user
docker run hello-world

echo
echo "DOCKER SUCCESFULLY INSTALLED"
echo
exit 0
