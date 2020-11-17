#!/usr/bin/bash

echo 
echo "INSTALLING DOCKER"
echo

echo "Install prerequisites"
echo
sudo apt update
if [ $? -ne 0 ]; then exit 2; fi

sudo apt -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
if [ $? -ne 0 ]; then exit 2; fi

echo
echo "Add Docker key"
echo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
if [ $? -ne 0 ]; then exit 2; fi

echo 
echo "Add docker repo. THIS MAY FAIL ON MINT, FIX"
echo
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
if [ $? -ne 0 ]; then exit 2; fi

echo
echo "Install docker packages"
echo
sudo apt update
sudo apt -y install docker-ce docker-ce-cli containerd.io
if [ $? -ne 0 ]; then exit 2; fi

echo
echo "Test docker as root"
echo
# Test #1 - as root
sudo docker run hello-world
if [ $? -ne 0 ]; then exit 2; fi

echo
echo "Add ${USER} to docker group"
echo
sudo groupadd docker
sudo usermod -aG docker $USER
if [ $? -ne 0 ]; then exit 2; fi

newgrp docker
if [ $? -ne 0 ]; then exit 2; fi
echo
echo "Test docker as regular user"
echo
# Test #2 - as a regular user
docker run hello-world
if [ $? -ne 0 ]; then exit 2; fi

echo
echo "DOCKER SUCCESFULLY INSTALLED"
echo
exit 0
