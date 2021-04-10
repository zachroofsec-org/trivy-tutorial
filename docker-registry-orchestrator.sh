#!/bin/bash

# +--------------------+
# SUMMARY
# +--------------------+

# 1) Builds (and uploads) Docker Images a remote Docker Registry
# 2) Checks if an Docker Image (in the remote registry) has been modified OUTSIDE of this script


# +--------------------+
# ASSUMPTIONS
# +--------------------+

# 1. Script should be triggered every 24 hours AND when Dockerfile modifications are made (at a minimum)

# 2. Dockerfiles pull in package updates on every build

# 3. Docker Image changes (in git) must be approved by a trusted entity
#   (Trivy can't find ALL docker vulnerabilities)

# 4. Script expects the following convention (shared with docker-scan.sh):
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

    # Generate Docker Image signature 
    # (used to detect Docker Image tampering)
    container-diff analyze --no-cache --format='{{(index .Analysis 0).Digest}}' daemon://"$local_image_name" > "$sig_abs_path"
    
    docker tag "$local_image_name" "$remote_image_name"
    docker push "$remote_image_name"
}

commit_and_push_signature() {
    local signature_absolute_path="$1"

    git add "$signature_absolute_path"
    git commit -m "Updating Docker Image signature"
    git push origin main
}


# +--------------------+
# MAIN LOGIC
# +--------------------+

# Git Configurations
git config user.name "Security Bot"
git config user.email "<>"
git pull origin main


# Iterate through Docker configurations (See Assumption 4 for path convention)
for docker_build_context_relative_path in docker-builder/registry-repos/*; do
    # Only iterate through directories
    [[ ! -d "$docker_build_context_relative_path" ]] && continue

    # Get the absolute path for the Docker configurations (i.e., build context)
    docker_build_context_absolute_path=$(realpath "$docker_build_context_relative_path")
    
    # Get the Docker Registry repo name from our path convention
    repo_name=$(basename "$docker_build_context_absolute_path")

    # Generate image names
    local_image_name="$repo_name:$TAG"
    
    # We download the remote image (within the Docker Registry) during the integrity checking process
    # (We'll soon see this)
    remote_image_name="$DOCKERHUB_USER/$local_image_name"

    # Local image build
    docker build --no-cache --tag "${local_image_name}" "${docker_build_context_absolute_path}"
    # We can now refer to this local image by its tag

    # +--------------------+
    # TAMPERING CHECKS SUMMARY
    # +--------------------+
    
    # If an attacker changes the registry's Docker Image, they subvert all 
    # preexisting controls
    # (i.e., Trivy scan, Pull Request Approval)

    # We need to ensure that a malicious Docker Image has NOT been placed in
    # the Docker Registry

    # For additional tampering checks, you should also use Docker Content Trust
    # (outside the scope of this tutorial)

    # +--------------------+
    # TAMPERING CHECK LOGIC
    # +--------------------+

    # Is this the first build of the Docker Image?
    # If so, we won't check for image tampering
    # signature_absolute_path is only available AFTER the first build
    
    signature_absolute_path="$docker_build_context_absolute_path/image_sha.txt"
    first_run=false
    if [[ ! -f "$signature_absolute_path" ]]; then
        # Signature does NOT exist
        first_run=true
    fi

    if [[ "$first_run" == "true" ]]; then
        # Use Google's container-diff tool to generate the
        # Docker Image signature
        # (on subsequent image builds, we'll validate that the remote Docker Image signature matches this signature)
        # Ex: sha256:9e81b4fc8735413c172a7595636957278b90c3613fb8983f4418208ba7ecab97
        generate_signature_and_upload_image "$local_image_name" "$remote_image_name" "$signature_absolute_path"
        
        # commit the signature into the "main" branch
        commit_and_push_signature "$signature_absolute_path"
        
        echo "First time building this Docker Image..."
        echo "Skipping integrity checks..."
        
        # Continue to next set of Docker configurations
        # (within the for loop)
        continue
    fi

    # This is NOT the first time this Docker Image has been built
    # Thus, we need to check for image tampering

    # Download remote version of Docker Image
    docker pull "${remote_image_name}"

    # Get the signature of the remote Docker Image
    remote_signature=$(container-diff analyze --no-cache --format='{{(index .Analysis 0).Digest}}' daemon://"$remote_image_name")
    # Get the signature of the Docker Image that was previously built
    previous_build_signature=$(cat "$signature_absolute_path")

    if [[ "${remote_signature}" != "${previous_build_signature}" ]]; then
        # The signatures do NOT match!
        
        echo "The remote signature does NOT match the previous build's signature!"
        echo "Docker Image tampering might be present in Dockerhub!"
        
        echo "Remote signature: $remote_signature"
        echo "Previous build signature: $previous_build_signature"
        echo "Docker Registry Repo: $repo_name"
        
        echo "Running Trivy scans on the remote Docker Image"
        
        # Ensure that Trivy does NOT scan a cached image
        trivy image --reset
    
        # For simplicity, we will use our previous scan settings
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

        echo "Not uploading Docker Image!"
        echo "An investigation needs to occur"
        
        # TODO: Send alert to SIEM
        
        exit 1
    else
        # The signatures DO match!
        
        echo "No Docker Image tampering is present!"
        generate_signature_and_upload_image "$local_image_name" "$remote_image_name" "$signature_absolute_path"
        commit_and_push_signature "$signature_absolute_path"
    fi
done
