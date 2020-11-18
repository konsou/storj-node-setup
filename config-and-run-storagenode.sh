#!/bin/bash
# source THIS SCRIPT!

# exit when any command fails
set -e

# MOUNT_POINT, IDENTITY_DIR and NODE_NAME must be set!
if [ -z "${MOUNT_POINT}" ]
then
    echo "MOUNT_POINT must be set"
    exit 1
fi

if [ -z "${IDENTITY_DIR}" ]  # directory where the signed identity is
then
    echo "IDENTITY_DIR must be set"
    exit 1
fi

if [ -z "${NODE_NAME}" ]
then
    echo "NODE_NAME must be set"
    exit 1
fi

# Node space calculation script is in Python
if [ $(dpkg-query -W -f='${Status}' python3 2>/dev/null | grep -c "ok installed") -eq 0 ]
then
    echo "Installing python3"
    sudo apt update
    sudo apt -y install python3
fi


# Port numbers and other needed info
read -p "Enter external Storj port to use (default is 28967): " PORT
read -p "Enter external dashboard port to use (default is 14002): " DASHBOARD_PORT
read -p "Enter wallet address: " WALLET_ADDRESS
read -p "Enter email address: " EMAIL_ADDRESS
read -p "Enter external ip or web address: " WEB_ADDRESS

echo "Current IPs are: "
hostname -I
echo "STATIC IP AND PORT FORWARDING MUST BE SET TO CONTINUE. PRESS ENTER IF THAT IS DONE."
read


TOTAL_SPACE=$(df ${MOUNT_POINT} --output='avail' --block-size=TB | grep 'TB')
AVAILABLE_SPACE=$(./calculate-node-space.py "${TOTAL_SPACE}")

# CREATE NEEDED DIRS
echo "Create ${MOUNT_POINT}/storagenode"
mkdir -p "${MOUNT_POINT}/storagenode"
echo "Move identity to ${MOUNT_POINT}"
mv "${IDENTITY_DIR}" "${MOUNT_POINT}"

docker pull storjlabs/storagenode:latest

DOCKER_RUN_SCRIPT=./docker-run.sh
# #!/bin/bash NEEDS TO BE IN SINGLE QUOTES TO WORK
echo '#!/bin/bash' > "${DOCKER_RUN_SCRIPT}"
echo "docker run -d --restart unless-stopped --stop-timeout 300 \\" >> "${DOCKER_RUN_SCRIPT}"
echo "    -p ${PORT}:28967 \\" >> "${DOCKER_RUN_SCRIPT}"
echo "    -p ${DASHBOARD_PORT}:14002 \\" >> "${DOCKER_RUN_SCRIPT}"
echo "    -e WALLET="${WALLET_ADDRESS}" \\" >> "${DOCKER_RUN_SCRIPT}"
echo "    -e EMAIL="${EMAIL_ADDRESS}" \\" >> "${DOCKER_RUN_SCRIPT}"
echo "    -e ADDRESS="${WEB_ADDRESS}:${PORT}" \\" >> "${DOCKER_RUN_SCRIPT}"
echo "    -e STORAGE="${AVAILABLE_SPACE}" \\" >> "${DOCKER_RUN_SCRIPT}"
echo "    --mount type=bind,source="${MOUNT_POINT}/identity/storagenode",destination=/app/identity \\" >> "${DOCKER_RUN_SCRIPT}"
echo "    --mount type=bind,source="${MOUNT_POINT}/storagenode",destination=/app/config \\" >> "${DOCKER_RUN_SCRIPT}"
echo "    --name "storagenode-${NODE_NAME}" storjlabs/storagenode:latest" >> "${DOCKER_RUN_SCRIPT}"

cat "${DOCKER_RUN_SCRIPT}"

read -p "PRESS ENTER TO CONTINUE IF THIS COMMAND LOOKS RIGHT. CTRL-C TO EXIT OTHERWISE."

echo "Running docker run command"
chmod +x "${DOCKER_RUN_SCRIPT}"
"${DOCKER_RUN_SCRIPT}"

echo "Setting up watchtower"
echo "Remove old watchtower - errors are ok here"
docker stop watchtower || true
docker rm watchtower || true

docker pull storjlabs/watchtower
echo "Run watchtower"
docker run -d --restart=always --name watchtower -v /var/run/docker.sock:/var/run/docker.sock storjlabs/watchtower --stop-timeout 300s