#!/bin/bash

sudo apt update
sudo apt upgrade

if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519
fi

# Pre-req for nvim
sudo apt-get install ninja-build gettext cmake unzip curl build-essential
# Clone, build, and install neovim

if [ ! -d ~/neovim ]; then
  # Ref: https://github.com/neovim/neovim/blob/master/BUILD.md#build-prerequisites
  git clone https://github.com/neovim/neovim ~/neovim
  cd ~/neovim && git checkout stable && make CMAKE_BUILD_TYPE=RelWithDebInfo
  cd build && cpack -G DEB && sudo dpkg -i nvim-linux64.deb
fi
# Setup neovim config
# Modified config of LayzVim Starter
# Ref: https://www.lazyvim.org
if [ -d ~/.config/nvim ]; then
  # Create backup
  sudo mv ~/.config/nvim{,.bak}
  sudo mv ~/.local/share/nvim{,.bak}
  sudo mv ~/.local/state/nvim{,.bak}
  sudo mv ~/.cache/nvim{,.bak}
fi
cp -r ~/ubuntu-setup/config/nvim ~/.config/nvim

if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
else
  cd ~/.fzf && git pull && ./install
fi

rm ~/.bash_aliases
rm ~/.bashrc
cat ~/ubuntu-setup/config/bash_aliases.txt >>~/.bash_aliases
cat ~/ubuntu-setup/config/bashrc.txt >>~/.bashrc
source ~/.bashrc

# Install nvm and npm
if ! hash nvm 2>/dev/null; then
  echo "Could not find nvm, installing it"
  # Ref: https://github.com/nvm-sh/nvm?tab=readme-ov-file
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
fi

# Ref: https://pipx.pypa.io/stable/
if ! hash pipx 2>/dev/null; then
  echo "Could not find pipx, installing it"
  sudo apt install pipx
  pipx ensurepath
  sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
  pipx run --spec ranger-fm ranger
fi
