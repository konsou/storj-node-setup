# storj-node-setup

## A script to help setting up your Storj node on Linux / Docker

## NOTE! I HAVEN'T TESTED YET AFTER ADDING THE NEW SETUP='true' DOCKER COMMAND!

## NOTE! CURRENTLY ONLY WORKS ON UBUNTU!

## Features
* can generate an identity for you (optional)
* can authorize your pregenerated identity (optional)
* cleans, partitions and formats your HDD to ext4 for you
* sets reserved space for the HDD to zero
* generates a name from HDD vendor and SN
* set the ext4 filesystem label to the generated name
* adds the new filesystem to fstab
* installs docker if needed (currently works only in Ubuntu)
* asks user for storagenode port, dashboard port, wallet address, email address and external address
* calculates HDD space for Storj automatically, reserving the recommended 10%
* generates and runs the docker run command
* sets up Watchtower for all docker images

## Usage

```
git clone https://github.com/konsou/storj-node-setup.git
cd storj-node-setup
./storj-node-setup.sh
```

Currently tested only on Ubuntu.

## This script is very much a work in progress - I'm not liable for bricking your computer (very unlikely) or destroying your data (somewhat unlikely unless you're careful)!

Feel free to submit bug reports or improvement suggestions!
