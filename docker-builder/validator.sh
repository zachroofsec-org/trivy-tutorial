#!/bin/bash
set -x

# Assumptions
#1. run within docker-builder directory
#2. Each docker image only leverages 1 tag

TAG=latest

for registry_rel_path in registry-repos/*; do
    [ -e "$registry_rel_path" ] || continue

    registry_abs_path=$(realpath $registry_rel_path)
    registry_name=$(basename $registry_abs_path)
    FULL_TAG="${registry_name}:${TAG}"

    docker pull "${FULL_TAG}"

    remote_sha=$(docker images --no-trunc --quiet "${FULL_TAG}") > ${registry_abs_path}/image_sha.txt
    local_sha=$(cat ${registry_abs_path}/image_sha.txt)

    if [[ "${remote_sha}" == "${local_sha}" ]]; then
        echo "they are different!"
        trivy --clear-cache
        trivy image "${FULL_TAG}"
        echo "Failing build so forensic investigation can take place"
        exit 1
    fi


done