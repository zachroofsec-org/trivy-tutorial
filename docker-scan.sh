#!/bin/bash
set -x

# +--------------------+
# SUMMARY
# +--------------------+

# Builds docker images and pushes them to remote Docker registry
# Checks if an image has vulnerabilities (via Trivy) BEFORE uploading to Docker registry
# Checks if an image (in the remote registry) has been modified OUTSIDE of this script

# +--------------------+
# ASSUMPTIONS
# +--------------------+

# 1. run script within docker-builder directory
# 2. Each docker image only leverages 1 tag
# 3. Script should be triggered every 24 hours AND when Dockerfile modifications are made
#    (allows package updates to occur)
# 4. Docker images pull in package updates on every build
# 5. Docker image changes (in git) must be approved by a trusted entity
#    (Trivy can't find ALL docker vulnerabilities)

# +--------------------+
# INPUTS
# +--------------------+

TAG="$1"
USER="$2"

TAG=latest
USER="zachroofsec"

# +--------------------+
# FUNCTIONS
# +--------------------+

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
    trivy image --reset "${local_image_name}"

    ## If image is vulnerable, stop image upload
    if [[ $? -ne 0 ]]; then
        exit 1
    fi
done