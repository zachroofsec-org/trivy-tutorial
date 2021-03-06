# What is this?
+ Supplementary repo for the course: [Container Infrastructure Analysis with Trivy](https://app.pluralsight.com/library/courses/container-infrastructure-analysis-trivy/)

# Main Setup Instructions
## Option 1: VM with everything installed (preferred method)
1. [Install Vagrant](https://www.vagrantup.com/docs/installation) 
2. `git clone https://github.com/zachroofsec/trivy-tutorial && cd trivy-tutorial`
3. `vagrant up && vagrant ssh`
4. `cd trivy-tutorial && bash start.sh`

## Option 2: Install yourself
1. Important
    + You must be on a recent version of Kali Linux (i.e., 2021.1.0)! 
    + There might be problems if package names change into the future
2. `git clone https://github.com/zachroofsec/trivy-tutorial.git && cd trivy-tutorial`
3. `bash install.sh && bash start.sh`

# Github Action Setup Instructions
## Dockerhub
1. Create [Dockerhub](https://hub.docker.com/) Account
2. Create `trivy-tutorial` [Dockerhub repo](https://docs.docker.com/docker-hub/repos/)
3. Create [Dockerhub Personal Access Token](https://docs.docker.com/docker-hub/access-tokens/)
## Github
1. [Fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) this repository into a **Github Organization**
2. Create an "automation" Github user
    + This user will be leveraged within a Github Action
    + Potential name: YOUR_REGULAR_USERNAME-automation
3. [Create a Personal Access Token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token) for the automation user
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

# Course Notes
+ TODO: [Docker Build Workflow: Novice]()
+ [https://www.justinsteven.com/posts/2021/02/14/docker-image-history-modification/](Docker History Modification)
+ [Github Actions Overview](https://docs.github.com/en/actions/learn-github-actions/introduction-to-github-actions#overview)
+ Infrastructure Analysis with kube-hunter

# Additional Resources Slide
