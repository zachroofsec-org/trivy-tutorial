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

generate_sig_and_publish_image() {
    local local_image_name="$1"
    local remote_image_name="$2"
    local sig_abs_path="$3"

    container-diff analyze --no-cache --format='{{(index .Analysis 0).Digest}}' daemon://"$local_image_name" > "$sig_abs_path"
    docker tag "$local_image_name" "$remote_image_name"
    docker push "$remote_image_name"
}

generate_sig_and_publish_image() {
    local sig_abs_path="$1"

    git add "$sig_abs_path"
    git commit -m "Updating SHA"
    git push origin master
}


# +--------------------+
# MAIN LOGIC
# +--------------------+

git config user.name "Security Bot"
git config user.email "<>"


for local_repo_rel_path in docker-builder/registry-repos/*; do
    [ -e "$local_repo_rel_path" ] || continue

    ## Get registry repo information from file structure
    local_docker_dir_abs_path=$(realpath "$local_repo_rel_path")
    repo_name=$(basename "$local_docker_dir_abs_path")

    ## Generate image names
    local_image_name="$repo_name:$TAG"
    remote_image_name="$USER/$local_image_name"

    ## Delete local images to ensure we dont leverage cached images
    docker image rm "$local_image_name" || true
    docker image rm "$remote_image_name" || true

    ## Local image build
    docker build --no-cache --tag "${local_image_name}" ${local_docker_dir_abs_path}

    ## Scan local image
    trivy image --reset "${local_image_name}" > /dev/null

    ## If image is vulnerable, stop image upload
    if [[ $? -ne 0 ]]; then
        exit 1
    fi

    # +--------------------+
    # TAMPERING CHECKS SUMMARY
    # +--------------------+
    # If an attacker changes the registy's docker image, they subvert all controls
    # (Trivy scan, Security Approval Step)

    # We need to ensure that a malicious docker image has NOT been placed in
    # the docker registry

    # For additional tampering checks, use Docker Content Trust
    # (outside the scope of this tutorial)

    # +--------------------+
    # TAMPERING CHECK LOGIC
    # +--------------------+

    ## Is this the first image?
    ## If so, we won't check for image tampering
    ## (this check occurs later)
    sig_abs_path="$local_docker_dir_abs_path/image_sha.txt"
    first_run=false
    if [ ! -f "$sig_abs_path" ]; then
        first_run=true
    fi


    if [[ "$first_run" == "true" ]]; then

        ## generate signature via Google's container-diff tool
        ## (on subsequent image builds, we'll validate that the remote docker image signature
        ## matches this signature)
        generate_sig_and_publish_image "$local_image_name" "$remote_image_name" "$sig_abs_path"
        echo "First run! Exiting"
        exit 0
    fi

    ## We are NOT on the first image build, thus we need to check for image tampering

    ## Pull remote image
    docker pull "${remote_image_name}"

    remote_sig=$(container-diff analyze --no-cache --format='{{(index .Analysis 0).Digest}}' daemon://"$remote_image_name")
    previous_build_sig=$(cat "$sig_abs_path")

    if [[ "${remote_sig}" != "${previous_build_sig}" ]]; then
        echo "they are different!"
        trivy image --reset "${local_image_name}"

        container-diff diff \
            --no-cache \
            --order \
            --type apt \
            --type file \
            --type history \
            --type layer \
            --type metadata \
            --type pip \
            --type size \
            --type sizelayer \
            daemon://$local_image_name\
            daemon://$remote_image_name

        trivy image --reset "${local_image_name}"

        echo "Failing build so forensic investigation can take place"
        exit 1
    else
        echo "they are the same!"
        generate_sig_and_publish_image "$local_image_name" "$remote_image_name" "$sig_abs_path"
    fi
done