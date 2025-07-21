#!/bin/sh

# Detect OS as best we can while maintaining POSIX compliance
OS=$(uname -s)
if [ "$OS" = "Linux" ]; then
  if grep -q "debian" /etc/os-release; then
    DISTRO="debian"
  elif grep -q "Arch" /etc/os-release; then
    DISTRO="arch"
  elif grep -q "rhel" /etc/os-release; then
    DISTRO="rhel"
  fi
elif [ "$OS" = "Darwin" ]; then
  DISTRO="macos"
fi

# Support installing dotfiles as a symlink (not used for devcontainers, but
# useful for setting up a new persistent environment)
if [ "$DOTFILES_INSTALL_MODE" = "link" ]; then
  alias dotinstall="ln -s"
else
  alias dotinstall="cp"
fi

# Ensure XDG variables are sane
if [ "$DISTRO" = "macos" ]; then
  if [ -z "$XDG_CACHE_HOME" ]; then
    XDG_CACHE_HOME="$HOME/Library/Caches"
  fi
  if [ -z "$XDG_CONFIG_DIRS" ]; then
    XDG_CONFIG_DIRS="$HOME/Library/Preferences:/Library/Application Support:/Library/Preferences:$HOME/.config"
  fi
  if [ -z "$XDG_CONFIG_HOME" ]; then
    XDG_CONFIG_HOME="$HOME/Library/Application Support"
  fi
  if [ -z "$XDG_DATA_DIRS" ]; then
    XDG_DATA_DIRS="/Library/Application Support:$HOME/.local/share"
  fi
  if [ -z "$XDG_DATA_HOME" ]; then
    XDG_DATA_HOME="$HOME/Library/Application Support"
  fi
  if [ -z "$XDG_STATE_HOME" ]; then
    XDG_STATE_HOME="$HOME/Library/Application Support"
  fi
  if [ -z "$XDG_RUNTIME_DIR" ]; then
    XDG_RUNTIME_DIR="$HOME/Library/Application Support"
  fi
else
  if [ -z "$XDG_CACHE_HOME" ]; then
    XDG_CACHE_HOME="$HOME/.cache"
  fi
  if [ -z "$XDG_CONFIG_HOME" ]; then
    XDG_CONFIG_HOME="$HOME/.config"
  fi
  if [ -z "$XDG_CONFIG_DIRS" ]; then
    XDG_CONFIG_DIRS="/etc/xdg"
  fi
  if [ -z "$XDG_DATA_DIRS" ]; then
    XDG_DATA_DIRS="/usr/local/share:/usr/share"
  fi
  if [ -z "$XDG_DATA_HOME" ]; then
    XDG_DATA_HOME="$HOME/.local/share"
  fi
  if [ -z "$XDG_STATE_HOME" ]; then
    XDG_STATE_HOME="$HOME/.local/state"
  fi
  if [ -z "$XDG_RUNTIME_DIR" ]; then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
  fi
  if [ -z "$XDG_STATE_HOME" ]; then
    XDG_STATE_HOME="$HOME/.local/state"
  fi
fi
if [ -z "$XDG_BIN_HOME" ]; then
  XDG_BIN_HOME="$HOME/.local/bin"
fi

if [ -z "$XDG_DESKTOP_DIR" ]; then
  XDG_DESKTOP_DIR="$HOME/Desktop"
fi
if [ -z "$XDG_DOCUMENTS_DIR" ]; then
  XDG_DOCUMENTS_DIR="$HOME/Documents"
fi
if [ -z "$XDG_DOWNLOAD_DIR" ]; then
  XDG_DOWNLOAD_DIR="$HOME/Downloads"
fi
if [ -z "$XDG_MOVIES_DIR" ]; then
  XDG_MOVIES_DIR="$HOME/Movies"
fi
if [ -z "$XDG_MUSIC_DIR" ]; then
  XDG_MUSIC_DIR="$HOME/Music"
fi
if [ -z "$XDG_PICTURES_DIR" ]; then
  XDG_PICTURES_DIR="$HOME/Pictures"
fi
if [ -z "$XDG_PUBLICSHARE_DIR" ]; then
  XDG_PUBLICSHARE_DIR="$HOME/Public"
fi
if [ -z "$XDG_TEMPLATES_DIR" ]; then
  XDG_TEMPLATES_DIR="$HOME/Templates"
fi

### $HOME

# GnuPG
if [ "$DISTRO" = "macos" ]; then
  mkdir -p "$HOME/.gnupg" && chmod 700 "$HOME/.gnupg"
  dotinstall HOME/.gnupg/gpg.conf "$HOME/.gnupg/gpg.conf"
  dotinstall HOME/.gnupg/gpg-agent.conf "$HOME/.gnupg/gpg-agent.conf"
else
  mkdir -p "$XDG_CONFIG_HOME/gnupg" && chmod 700 "$XDG_CONFIG_HOME/gnupg"
  dotinstall HOME/.gnupg/gpg.conf "$HOME/.gnupg/gpg.conf"
  dotinstall HOME/.gnupg/gpg-agent.conf "$HOME/.gnupg/gpg-agent.conf"
fi

# SSH
mkdir -p "$HOME/.ssh" && chmod 755 "$HOME/.ssh"
touch "$HOME/.ssh/config-home"

if [ "$DISTRO" = "macos" ]; then
  mkdir -p "$HOME/.orbstack/ssh" && chmod 755 "$HOME/.orbstack/ssh"
  touch "$HOME/.orbstack/ssh/config"
  dotinstall HOME/.ssh/config_macos "$HOME/.ssh/config"
else
  dotinstall HOME/.ssh/config "$HOME/.ssh/config"
fi

# login
dotinstall HOME/.hushlogin "$HOME/.hushlogin"

### $XDG_BIN_HOME
mkdir -p "$XDG_BIN_HOME"

if [ "$DOTFILES_INSTALL_MODE" = "link" ]; then
  for file in XDG_BIN_HOME/*; do
    ln -s "$file" "$XDG_BIN_HOME/"
  done
else
  cp XDG_BIN_HOME/* "$XDG_BIN_HOME/"
fi

### $XDG_CONFIG_HOME

# curl
dotinstall "XDG_CONFIG_HOME/.curlrc" "$XDG_CONFIG_HOME/.curlrc"

# docker
mkdir -p "$XDG_CONFIG_HOME/docker"

# gem
mkdir -p "$XDG_CONFIG_HOME/gem"

# gcloud
mkdir -p "$XDG_CONFIG_HOME/gcloud"

# Ghostty
if [ "$DISTRO" = "macos" ]; then
  mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
  dotinstall "HOME/Library/Application Support/com.mitchellh.ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
else
  mkdir -p "$XDG_CONFIG_HOME/ghostty"
  dotinstall "XDG_CONFIG_HOME/ghostty/config" "$XDG_CONFIG_HOME/ghostty/config"
fi

# Git
mkdir -p "$XDG_CONFIG_HOME/git"
dotinstall "XDG_CONFIG_HOME/git/attributes" "$XDG_CONFIG_HOME/git/attributes"
dotinstall "XDG_CONFIG_HOME/git/ignore" "$XDG_CONFIG_HOME/git/ignore"

if [ "$DISTRO" = "macos" ]; then
  dotinstall "XDG_CONFIG_HOME/git/config_macos" "$XDG_CONFIG_HOME/git/config"
elif [ -f "/proc/sys/fs/binfmt_misc/WSLInterop" ]; then
  dotinstall "XDG_CONFIG_HOME/git/config_wsl" "$XDG_CONFIG_HOME/git/config"
else
  dotinstall "XDG_CONFIG_HOME/git/config" "$XDG_CONFIG_HOME/git/config"
fi

# nano
mkdir -p "$XDG_CONFIG_HOME/nano"
dotinstall "XDG_CONFIG_HOME/nano/nanorc" "$XDG_CONFIG_HOME/nano/nanorc"

# npm
mkdir -p "$XDG_CONFIG_HOME/npm"
dotinstall "XDG_CONFIG_HOME/npm/npmrc" "$XDG_CONFIG_HOME/npm/npmrc"

# pip
mkdir -p "$XDG_CONFIG_HOME/pip"
dotinstall "XDG_CONFIG_HOME/pip/default-python-packages" "$XDG_CONFIG_HOME/pip/default-python-packages"

# python
mkdir -p "$XDG_CONFIG_HOME/python"
mkdir -p "$XDG_CONFIG_HOME/ipython"
mkdir -p "$XDG_CONFIG_HOME/jupyter"
dotinstall "XDG_CONFIG_HOME/python/pythonrc" "$XDG_CONFIG_HOME/python/pythonrc"

# readline
mkdir -p "$XDG_CONFIG_HOME/readline"
dotinstall "XDG_CONFIG_HOME/readline/inputrc" "$XDG_CONFIG_HOME/readline/inputrc"

# screen
mkdir -p "$XDG_CONFIG_HOME/screen"
dotinstall "XDG_CONFIG_HOME/screen/screenrc" "$XDG_CONFIG_HOME/screen/screenrc"

# starship
mkdir -p "$XDG_CONFIG_HOME/starship"
dotinstall "XDG_CONFIG_HOME/starship/starship.toml" "$XDG_CONFIG_HOME/starship/starship.toml"

# vim
mkdir -p "$XDG_CONFIG_HOME/vim"
dotinstall "XDG_CONFIG_HOME/vim/vimrc" "$XDG_CONFIG_HOME/vim/vimrc"

# wget
dotinstall "XDG_CONFIG_HOME/wgetrc" "$XDG_CONFIG_HOME/wgetrc"

### $XDG_CACHE_HOME
# npm
mkdir -p "$XDG_CACHE_HOME/npm"

# starship
mkdir -p "$XDG_CACHE_HOME/starship"

# vim
mkdir -p "$XDG_CACHE_HOME/vim"

### $XDG_DATA_HOME
# ansible
mkdir -p "$XDG_DATA_HOME/ansible"

# cargo
mkdir -p "$XDG_DATA_HOME/cargo"

# enhancd
mkdir -p "$XDG_DATA_HOME/enhancd"

# npm
mkdir -p "$XDG_DATA_HOME/npm"

### $XDG_STATE_HOME

# less
mkdir -p "$XDG_STATE_HOME/less"

# ZDOTDIR
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
git clone --recurse-submodules https://github.com/belak/prezto-contrib "${ZDOTDIR:-$HOME}/.zprezto/contrib"

rm -f "${ZDOTDIR:-$HOME}"/.zlogin
rm -f "${ZDOTDIR:-$HOME}"/.zlogout
rm -f "${ZDOTDIR:-$HOME}"/.zprofile
rm -f "${ZDOTDIR:-$HOME}"/.zshenv

ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zlogin "${ZDOTDIR:-$HOME}"/.zlogin
ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zlogout "${ZDOTDIR:-$HOME}"/.zlogout
ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zprofile "${ZDOTDIR:-$HOME}"/.zprofile
ln -s "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/zshenv "${ZDOTDIR:-$HOME}"/.zshenv

dotinstall ZDOTDIR/.aliases "${ZDOTDIR:-$HOME}"/.aliases
dotinstall ZDOTDIR/.exports "${ZDOTDIR:-$HOME}"/.exports
dotinstall ZDOTDIR/.functions "${ZDOTDIR:-$HOME}"/.functions
dotinstall ZDOTDIR/.sources "${ZDOTDIR:-$HOME}"/.sources
dotinstall ZDOTDIR/.zmodules "${ZDOTDIR:-$HOME}"/.zmodules
dotinstall ZDOTDIR/.zpreztorc "${ZDOTDIR:-$HOME}"/.zpreztorc
dotinstall ZDOTDIR/.zshrc "${ZDOTDIR:-$HOME}"/.zshrc

touch "${ZDOTDIR:-$HOME}/.aliases_private"
touch "${ZDOTDIR:-$HOME}/.exports_private"
touch "${ZDOTDIR:-$HOME}/.functions_private"
touch "${ZDOTDIR:-$HOME}/.sources_private"

if command -v zsh >/dev/null 2>&1; then
  sudo chsh "$(id -un)" --shell "$(which zsh)"
fi
