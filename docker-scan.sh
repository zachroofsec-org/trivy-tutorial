#!/bin/bash
set -x

# +--------------------+
# SUMMARY
# +--------------------+

# Checks if an image has vulnerabilities (via Trivy) BEFORE uploading to Docker registry

# Dockerfile -> Docker Image -> Docker Container

# Dockerfile: Docker Configurations
# Docker Image: A lean Virtual Machine Image (i.e., .iso)
# Docker Container: A running application (similar to a running Virtual Machine)

# Docker Images are stored within a Docker Repository
# Docker Repositories are housed within a Docker Registry (e.g., Dockerhub)
# In this tutorial, our Docker Registry will be Dockerhub
# https://hub.docker.com/repository/docker/zachroofsec/ps-trivy

# This workflow scans all Docker Images BEFORE they are uploaded (i.e., pushed)
# to Dockerhub.  The upload step occurs in `builder.yml` workflow

# Workflow expects the following convention:
# /docker-builder/registry-repos/REPO_NAME/Dockerfile


# +--------------------+
# ASSUMPTIONS
# +--------------------+

# 1. run script within docker-builder directory
# 3. Script should be triggered on Pull Requests
#    (allows package updates to occur)
# 4. Docker images pull in package updates on every build
# 5. Docker image changes (in git) must be approved by a trusted entity
#    (Trivy can't find ALL docker vulnerabilities)

# +--------------------+
# MAIN LOGIC
# +--------------------+

for local_repo_rel_path in docker-builder/registry-repos/*; do
    [ -e "$local_repo_rel_path" ] || continue

    ## Get registry repo information from file structure
    local_docker_dir_abs_path=$(realpath "$local_repo_rel_path")

    ## Generate image names
    local_image_name=test-image

    ## Delete local images to ensure we dont leverage cached images
    ## (helps with local development)
    docker image rm "$local_image_name" || true

    ## Local image build
    docker build --no-cache --tag "${local_image_name}" ${local_docker_dir_abs_path}

    ## Scan local image
    trivy image --reset
    trivy image "${local_image_name}"

    ## If image is vulnerable, stop image upload
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
done