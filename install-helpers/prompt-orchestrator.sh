#!/bin/bash
set -x

# Script assumes usage of bash shell
chsh -s /bin/bash vagrant

# Stop log in messages
touch "/home/vagrant/.hushlogin"

# Misc paths
PARENT_DIR_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
INSTALLER_PATH=$PARENT_DIR_PATH/prompt-installer.sh
BASHRC_PATH="${HOME}/.bashrc"

INIT_COMMAND='eval "$(starship init bash)"'
grep -Rq "${INIT_COMMAND}" "${BASHRC_PATH}"
if [[ $? -eq 0 ]]; then
    echo 'Custom prompt (starship) has already been installed'
else
    echo 'Installing custom prompt (starship)'
    bash "$INSTALLER_PATH" --force
    echo "export STARSHIP_CONFIG=$PARENT_DIR_PATH/starship.toml" >> /home/vagrant/.bashrc
    echo 'eval "$(starship init bash)"' >> /home/vagrant/.bashrc
fi