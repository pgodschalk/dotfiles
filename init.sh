#!/usr/bin/env bash
set -euf -o pipefail

REPOPATH=$1

if [[ $OSTYPE == "linux-gnu"* ]]; then
  if grep -q "Debian" /etc/os-release; then
    export DISTRO="debian"
  elif grep -q "Arch" /etc/os-release; then
    export DISTRO="arch"
  elif grep -q "rhel" /etc/os-release; then
    export DISTRO="rhel"
  fi
elif [[ $OSTYPE == "darwin"* ]]; then
  export DISTRO="macos"
fi

# Check deps
if ! command -v nano 2>/dev/null; then
  echo "nano not installed, exiting"
  exit 1
fi

if ! command -v git 2>/dev/null; then
  echo "git not installed, exiting"
  exit 1
fi

if echo $SHELL | grep -q zsh; then
  echo "zsh is not set as shell, exiting"
  exit 1
fi

if [ -d ~/.zprezto ]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git \
  "${ZDOTDIR:-$HOME}/.zprezto"
  setopt EXTENDED_GLOB
  for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  done
  git clone --recurse-submodules https://github.com/belak/prezto-contrib \
  "${ZDOTDIR:-$HOME}/.zprezto/contrib"
fi

# scripts
mkdir -p ~/Code
rm -rf ~/Code/bin
ln -s ~/Code/bin $REPOPATH/bin

if [ -d ~/Code/build/scopatz/nanorc ]; then
  mkdir -p ~/Code/build
  mkdir -p ~/Code/build/scopatz
  git clone https://github.com/scopatz/nanorc.git ~/Code/build/scopatz/nanorc
fi

# zsh environment
rm -f ~/.aliases
rm -f ~/.exports
rm -f ~/.functions
rm -f ~/.zmodules
rm -f ~/.zpreztorc
rm -f ~/.zshenv
rm -f ~/.zshrc
ln -s $REPOPATH/.aliases ~/.aliases
ln -s $REPOPATH/.exports ~/.exports
ln -s $REPOPATH/.functions ~/.functions
ln -s $REPOPATH/.zmodules ~/.zmodules
ln -s $REPOPATH/.zpreztorc ~/.zpreztorc
ln -s $REPOPATH/.zshenv ~/.zshenv
ln -s $REPOPATH/.zshrc ~/.zshrc

# editorconfig
rm -f ~/.editorconfig
ln -s $REPOPATH/.editorconfig ~/.editorconfig

# git
rm -f ~/.gitconfig
rm -f ~/.gitignore_global
ln -s $REPOPATH/.gitconfig ~/.gitconfig
ln -s $REPOPATH/.gitignore_global ~/.gitignore_global

# hushlogin
rm -f ~/.hushlogin
ln -s $REPOPATH/.hushlogin ~/.hushlogin

# nano
rm -f ~/.nanorc
ln -s $REPOPOATH/.nanorc ~/.nanorc

# composer
if command -v composer 2>/dev/null; then
  composer global require squizlabs/php_codesniffer
  rm -f         ~/.composer/vendor/squizlabs/php_codesniffer/CodeSniffer.conf
  ln -s $REPOPATH/.composer/vendor/squizlabs/php_codesniffer/CodeSniffer.conf \
                ~/.composer/vendor/squizlabs/php_codesniffer/CodeSniffer.conf
fi

# Karabiner
if [ $DISTRO == "macos" ]; then
  if [ -d /Applications/Karabiner-Elements.app ]; then
    rm -f           ~/.config/karabiner/karabiner.json
    ln -s $REPOPATH ~/.config/karabiner/karabiner.json \
                    ~/.config/karabiner/karabiner.json
  fi
fi

# micro
if command -v micro 2>/dev/null; then
  rm -f         ~/.config/micro/bindings.json
  rm -f         ~/.config/micro/settings.json
  ln -s $REPOPATH/.config/micro/bindings.json \
                ~/.config/micro/bindings.json
  ln -s $REPOPATH/.config/micro/settings.json \
                ~/.config/micro/settings.json

# gpg
if command -v gpg 2>/dev/null; then
  rm -f         ~/.gnupg/gpg.conf
  rm -f         ~/.gnupg/gpg-agent.conf
  ln -s $REPOPATH/.gnupg/gpg.conf \
                ~/.gnupg/gpg.conf
  ln -s $REPOPATH/.gnupg/gpg-agent.conf \
                ~/.gnupg/gpg-agent.conf
fi

# ssh
if command -v ssh 2>/dev/null; then
  rm -f         ~/.ssh/config
  ln -s $REPOPATH/.ssh/config \
                ~/.ssh/config
fi

# code
if command -v code 2>/dev/null; then
  rm -f ~/Library/Application\ Support/Code/User/Settings.json
  ln -s $REPOPATH/Application\ Support/Code/User/Settings.json \
        ~/Library/Application\ Support/Code/User/Settings.json
fi

# ansible
if command -v ansible 2>/dev/null; then
  rm -f         ~/.ansible.cfg
  ln -s $REPOPATH/.ansible.cfg \
                ~/.ansible.cfg
fi

# curl
if command -v curl 2>/dev/null; then
  rm -f         ~/.curlrc
  ln -s $REPOPATH/.curlrc \
                ~/.curlrc
fi

# dig
if command -v dig 2>/dev/null; then
  rm -f         ~/.digrc
  ln -s $REPOPATH/.digrc \
                ~/.digrc
fi

# screen
if command -v screen 2>/dev/null; then
  rm -rf        ~/.screenrc
  ln -s $REPOPATH/.screenrc \
                ~/.screenrc
fi

# vue
if cmomand -v vue-cli 2>/dev/null; then
  rm -f         ~/.vuerc
  ln -s $REPOPATH/.vuerc \
                ~/.vuerc
fi
