#!/bin/bash
# set -x

# +--------------------+
# GENERAL
# +--------------------+

## Installs dependencies for the attack simulation environment
## Tested on FRESH install of Kali Linux 2021.1.0 on 2/2021

# NOTE: This script is NOT guaranteed to work into the future
# (packages can be removed from package repositories)

# +--------------------+
# APT INSTALLS
# +--------------------+
export DEBIAN_FRONTEND=noninteractive

distro="$(lsb_release -sc)"
if [[ "$distro" -eq "kali-rolling" ]]; then
    # kali 2021.1.0 is based on buster
    # We set the distro to make trivy install correctly
    distro="buster"
fi

sudo apt-get -y update &&\
    sudo apt-get -y install wget \
        apt-transport-https \
        gnupg \
        lsb-release &&\
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add - &&\
        echo deb https://aquasecurity.github.io/trivy-repo/deb $distro main | sudo tee -a /etc/apt/sources.list.d/trivy.list &&\
        sudo apt-get update && sudo apt-get install -y trivy

if [[ "$GITHUB_ACTIONS" == "true" ]]; then
    echo "Running within a Github Action.  Not installing docker"
else
    sudo apt-get install docker.io &&\
        # Allow docker-builder to run as non-root
        sudo usermod -aG docker $USER
fi


echo "----------------------------------------------------------------"
echo "Installation finished!"
echo "----------------------------------------------------------------"
