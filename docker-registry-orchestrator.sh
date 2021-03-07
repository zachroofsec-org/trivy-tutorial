#!/bin/bash

# +--------------------+
# SUMMARY
# +--------------------+

# Builds Docker Images and uploads them to remote Docker Registry
# Checks if an Docker Image (in the remote registry) has been modified OUTSIDE of this script


# +--------------------+
# ASSUMPTIONS
# +--------------------+

# 1. Script should be triggered every 24 hours AND when Dockerfile modifications are made
#    (allows package updates to occur)

# 2. Docker Images pull in package updates on every build

# 3. Docker Image changes (in git) must be approved by a trusted entity
#   (Trivy can't find ALL docker vulnerabilities)

# 4. Script expects the following convention:
#     trivy-tutorial/docker-builder/registry-repos/REPO_NAME/Dockerfile
#     (e.g., trivy-tutorial/docker-builder/registry-repos/trivy-tutorial/Dockerfile)

# +--------------------+
# INPUTS
# +--------------------+

# Docker Tags are a way to version Docker Images
# In this demo, we build Docker Images with the "latest" tag
TAG="$1"

## In this demo, zachroofsec
DOCKERHUB_USER="$2"

# +--------------------+
# FUNCTIONS
# +--------------------+

generate_signature_and_upload_image() {
    local local_image_name="$1"
    local remote_image_name="$2"
    local sig_abs_path="$3"

    container-diff analyze --no-cache --format='{{(index .Analysis 0).Digest}}' daemon://"$local_image_name" > "$sig_abs_path"
    docker tag "$local_image_name" "$remote_image_name"
    docker push "$remote_image_name"
}

commit_and_push_signature() {
    local signature_absolute_path="$1"

    git add "$signature_absolute_path"
    git commit -m "Updating Docker Image Signatures"
    git push origin main
}


# +--------------------+
# MAIN LOGIC
# +--------------------+

# GIT Set up
git config user.name "Security Bot"
git config user.email "<>"
git pull origin main


# Iterate through Docker configurations (See Assumption 4 for path convention)
for docker_build_context_relative_path in docker-builder/registry-repos/*; do
    # Only iterate through directories
    [[ ! -d "$docker_build_context_relative_path" ]] && continue

    # Get the absolute path for the Docker configurations (i.e., build context)
    docker_build_context_absolute_path=$(realpath "$docker_build_context_relative_path")
    
    # Get the Docker Registry repo name from path
    repo_name=$(basename "$docker_build_context_absolute_path")

    # Generate image names
    local_image_name="$repo_name:$TAG"
    
    # We download the remote image (within the Docker Registry) during the integrity checking process
    # (We'll soon see this)
    remote_image_name="$DOCKERHUB_USER/$local_image_name"

    # Local image build
    docker build --no-cache --tag "${local_image_name}" "${docker_build_context_absolute_path}"

    # +--------------------+
    # TAMPERING CHECKS SUMMARY
    # +--------------------+
    
    # If an attacker changes the registry's Docker Image, they subvert all 
    # preexisting controls
    # (i.e., Trivy scan, Pull Request Approval)

    # We need to ensure that a malicious Docker Image has NOT been placed in
    # the docker registry

    # For additional tampering checks, you should also use Docker Content Trust
    # (outside the scope of this tutorial)

    # +--------------------+
    # TAMPERING CHECK LOGIC
    # +--------------------+

    # Is this the first build of the Docker Image?
    # If so, we won't check for image tampering
    
    signature_absolute_path="$docker_build_context_absolute_path/image_sha.txt"
    first_run=false
    if [[ ! -f "$signature_absolute_path" ]]; then
        first_run=true
    fi

    if [[ "$first_run" == "true" ]]; then
        # generate Docker Image signature via Google's container-diff tool
        # (on subsequent image builds, we'll validate that the remote Docker Image signature
        # matches this signature)
        # Ex: sha256:9e81b4fc8735413c172a7595636957278b90c3613fb8983f4418208ba7ecab97
        generate_signature_and_upload_image "$local_image_name" "$remote_image_name" "$signature_absolute_path"
        
        # commit the signature into the "main" branch
        commit_and_push_signature "$signature_absolute_path"
        
        echo "First time building this Docker Image..."
        echo "Skipping integrity checks..."
        exit 0
    fi

    # This is NOT the first time this Docker Image has been built
    # Thus, we need to check for image tampering

    # Download remote version of Docker Image
    docker pull "${remote_image_name}"

    # Get the signature of the Docker Image (remote version)
    remote_signature=$(container-diff analyze --no-cache --format='{{(index .Analysis 0).Digest}}' daemon://"$remote_image_name")
    # Get the signature of the Docker Image that was previously built
    previous_build_signature=$(cat "$signature_absolute_path")

    if [[ "${remote_signature}" != "${previous_build_signature}" ]]; then
        
        echo "The remote signature does NOT match the previous build's signature!"
        echo "Docker Image Tampering might be present in Dockerhub!"
        
        echo "Remote signature: $remote_signature"
        echo "Previous build signature: $previous_build_signature"
        echo "Docker Registry Repo: $repo_name"
        
        
        echo "Running Trivy scans of the remote Docker Image"
        
        # Ensure that Trivy does NOT scan a cached image
        trivy image --reset
    
        # For simplicity, we will use the same Trivy scan
        trivy image --no-progress --severity CRITICAL,HIGH,MEDIUM --ignore-unfixed "${remote_image_name}"
        

        echo "Looking at differences between the Docker Images"
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

        echo "Stopping the upload process so an forensic investigation can take place"
        # TODO: Add in alerting logic
        
        exit 1
    else
        echo "No Docker Image tampering is present!"
        generate_signature_and_upload_image "$local_image_name" "$remote_image_name" "$signature_absolute_path"
        commit_and_push_signature "$signature_absolute_path"
    fi
done