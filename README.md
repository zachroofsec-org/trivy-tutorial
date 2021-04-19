# What is this?

+ A supplementary repo for the course: [Container Infrastructure Analysis with Trivy](https://app.pluralsight.com/library/courses/container-infrastructure-analysis-trivy/)

# Main Setup Instructions

## Option 1: VM with everything installed **(preferred method)**

1. [Install Vagrant](https://www.vagrantup.com/docs/installation)
2. `git clone https://github.com/zachroofsec-org/trivy-tutorial.git && cd trivy-tutorial`
3. `vagrant up && vagrant ssh`
4. `cd trivy-tutorial`

## Option 2: Install yourself

1. Important
    + You must be on a recent version of Kali Linux (e.g., 2021.1.0)!
    + There might be problems if package names change into the future
2. `git clone https://github.com/zachroofsec-org/trivy-tutorial.git && cd trivy-tutorial`
3. `bash install.sh`

# Github Action Setup Instructions **(advanced)**

## Dockerhub

1. Create a [Dockerhub](https://hub.docker.com/) account
2. Create `trivy-tutorial` [Dockerhub repo](https://docs.docker.com/docker-hub/repos/)
3. Create [Dockerhub Personal Access Token](https://docs.docker.com/docker-hub/access-tokens/)

## Github

1. [Fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) this repository into a [Github Organization](https://docs.github.com/en/github/setting-up-and-managing-organizations-and-teams/creating-a-new-organization-from-scratch)
2. `git clone INSERT_FORK_LINK_HERE`
    + NOTE: From now on, you will leverage this forked repo for experimentation. You can NOT use the `zachroofsec-org/trivy-tutorial` repo
3. Create an "automation" Github user
    + This user will be leveraged within a Github Action
    + A potential name: `YOUR_REGULAR_USERNAME-automation`
4. [Create a Personal Access Token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) for the automation user
    + Select the `repo` scope
5. [Invite the automation user](https://docs.github.com/en/github/setting-up-and-managing-organizations-and-teams/managing-membership-in-your-organization) to the Github Organization
    + The user must have `owner` permissions
        + This is needed to override branch protection rules
6. [Attach secrets](https://docs.github.com/en/actions/reference/encrypted-secrets) to the forked repo
    + `DOCKERHUB_USERNAME`
    + `DOCKERHUB_PASSWORD`
        + NOTE: Use the Dockerhub Personal Access Token
    + `GIT_AUTOMATION_USER_TOKEN`
        + NOTE: Use the Github Personal Access Token

# Special Thanks

+ Teppei Fukuda
    + [Github](https://github.com/knqyf263)
    + [Twitter](https://twitter.com/knqyf263)

# Course Links

## Pluralsight Courses

+ [Infrastructure Analysis with kube-hunter](https://app.pluralsight.com/library/courses/container-infrastructure-analysis-kube-hunter)
    + NOTE: Course dives deeper into Docker Registry tampering
+ [Getting Started With Docker](https://app.pluralsight.com/library/courses/getting-started-docker)

## Youtube

+ [Webinar: Trivy Open Source Scanner for Container Images – Just Download and Run!](https://www.youtube.com/watch?v=XnYxX9uueoQ)
+ [Handling Container Vulnerabilities with Open Policy Agent - Teppei Fukuda, Aqua Security](https://www.youtube.com/watch?v=WKE2XNZ2zr4)

## Blogs/Documentation

+ [Trivy README](https://github.com/aquasecurity/trivy)
+ [Trivy Visual Studio Code Extension](https://github.com/aquasecurity/trivy-vscode-extension)
+ [Harbor Scanner Adapter for Trivy](https://github.com/aquasecurity/harbor-scanner-trivy)
+ [Docker Image History Modification](https://www.justinsteven.com/posts/2021/02/14/docker-image-history-modification)
+ [Github Actions Overview](https://docs.github.com/en/actions/learn-github-actions/introduction-to-github-actions#overview)
+ [container-diff](https://github.com/GoogleContainerTools/container-diff)

