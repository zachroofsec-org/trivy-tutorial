#!/bin/bash
set -x

chmod +x /home/vagrant/trivy-tutorial/install-helpers/prompt-installer.sh
/home/vagrant/trivy-tutorial/install-helpers/prompt-installer.sh --force
echo 'export STARSHIP_CONFIG=/home/vagrant/.config/starship.toml' >> /home/vagrant/.bashrc
echo 'eval "$(starship init bash)"' >> /home/vagrant/.bashrc
cp /home/vagrant/trivy-tutorial/install-helpers/starship.toml /home/vagrant/.config/starship.toml