#!/bin/bash

sudo apt update
sudo apt upgrade

if [ ! -f ~/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519
fi

# Pre-req for nvim
sudo apt-get install ninja-build gettext cmake unzip curl build-essential python3-pip
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

# Lua and Luarocks
sudo apt install lua5.1 liblua5.1-dev
wget https://luarocks.org/releases/luarocks-3.11.1.tar.gz
tar zxpf luarocks-3.11.1.tar.gz
cd luarocks-3.11.1 && ./configure && make && sudo make install && cd .. || return
sudo luarocks install luasocket
rm -rf luarocks-3*

sudo apt-get install ripgrep
sudo apt install fd-find

cp -r ~/ubuntu-setup/config/nvim ~/.config/nvim

if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install
else
  cd ~/.fzf && git pull && ./install
fi

cat ~/ubuntu-setup/config/bash_aliases.txt >~/.bash_aliases
cat ~/ubuntu-setup/config/bashrc.txt >~/.bashrc
source ~/.bashrc

# Install nvm and npm
if ! hash nvm 2>/dev/null; then
  echo "Could not find nvm, installing it"
  # Ref: https://github.com/nvm-sh/nvm?tab=readme-ov-file
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

  nvm install 20
  # verifies the right Node.js version is in the environment
  node -v # should print `v20.18.0`

  # verifies the right npm version is in the environment
  npm -v # should print `10.8.2`
  pip install tree-sitter
  pip install --upgrade pynvim
  npm install -g tree-sitter-cli
  npm install -g neovim
fi

# Install clipboard capture
sudo apt install xclip

# Ref: https://pipx.pypa.io/stable/
if ! hash pipx 2>/dev/null; then
  echo "Could not find pipx, installing it"
  sudo apt install pipx
  pipx ensurepath
  sudo pipx ensurepath --global # optional to allow pipx actions with --global argument
  pipx run --spec ranger-fm ranger
fi

git config --global core.editor "vi"

if ! hash lazygit 2>/dev/null; then
  # Ref: https://github.com/jesseduffield/lazygit?tab=readme-ov-file#installation
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit /usr/local/bin
  rm lazygit lazygit.tar.gz
fi
