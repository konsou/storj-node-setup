#!/bin/bash

# exit when any command fails
set -e

echo 
echo "INSTALLING DOCKER"
echo

if [[ \
    $(dpkg-query -W -f='${Status}' docker-ce 2>/dev/null | grep -c "ok installed") -eq 1 && \
    $(dpkg-query -W -f='${Status}' docker-ce-cli 2>/dev/null | grep -c "ok installed") -eq 1 && \
    $(dpkg-query -W -f='${Status}' containerd.io 2>/dev/null | grep -c "ok installed") -eq 1 \
]]
then
    echo "Docker already installed"
    exit 0
fi

echo "Install prerequisites"
echo

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
echo "Add docker repo. THIS MAY FAIL IF YOU'RE NOT USING UBUNTU!"
echo
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo
echo "Install docker packages"
echo
sudo apt -y install docker-ce docker-ce-cli containerd.io

echo
echo "Test docker as root"
echo
sudo docker run hello-world

echo
echo "Add ${USER} to docker group"
echo
sudo usermod -aG docker $USER

echo
echo "Test docker as regular user"
echo
newgrp docker << END
docker run hello-world
END

echo
echo "DOCKER SUCCESFULLY INSTALLED"
echo
exit 0
