#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

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

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Source iTerm2 Shell Integration
if [[ -s "${HOME}/.iterm2_shell_integration.zsh" ]]; then
  source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Source Z
if [[ -s /usr/local/etc/profile.d/z.sh ]]; then
  source /usr/local/etc/profile.d/z.sh
fi

# Brew completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
  autoload -Uz compinit
  compinit
fi

# Source Prezto modules depending on current environment
if [[ -s "${HOME}/.zmodules" ]]; then
  source "${HOME}/.zmodules"
fi

# Custom
if [[ -s "${HOME}/.aliases" ]]; then
  source "${HOME}/.aliases"
fi
if [[ -s "${HOME}/.exports" ]]; then
  source "${HOME}/.exports"
fi
if [[ -s "${HOME}/.functions" ]]; then
  source "${HOME}/.functions"
fi

# Session for Bitwarden CLI
if [[ -s "${HOME}/.bwsession" ]]; then
  source "${HOME}/.bwsession"
fi

# Auth token for DigitalOcean
if [[ -s "${HOME}/.dotoken" ]]; then
  source "${HOME}/.dotoken"
fi
