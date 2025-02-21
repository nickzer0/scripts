#!/bin/bash

sudo apt update

apt install zsh git curl -y

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

USER_HOME=$(eval echo ~${SUDO_USER:-$USER})

sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="gianu"/g' "$USER_HOME/.zshrc"

chsh -s /bin/zsh

echo "Zsh installed and theme set to 'gianu' for user: ${SUDO_USER:-$USER}"
