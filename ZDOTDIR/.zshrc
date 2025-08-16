#!/usr/bin/env zsh
# shellcheck disable=SC1091

# We use this to determine which OS specific plugins to load
if [[ $OSTYPE == "linux-gnu"* ]]; then
  if grep --quiet "debian" /etc/os-release; then
    export DISTRO="debian"
  elif grep --quiet "Arch" /etc/os-release; then
    export DISTRO="arch"
  elif grep --quiet "rhel" /etc/os-release; then
    export DISTRO="rhel"
  fi
elif [[ $OSTYPE == "darwin"* ]]; then
  export DISTRO="macos"
fi

if [[ -s "${ZDOTDIR:-$HOME}/.sources" ]]; then
  source "${ZDOTDIR:-$HOME}/.sources"
fi

# SSH agent
if [ -z "$SSH_AUTH_SOCK" ]; then
  # Check for a currently running instance of the agent
  RUNNING_AGENT="$(pgrep ssh-agent)"

  if [ "$RUNNING_AGENT" = "0" ]; then
    # Launch a new instance of the agent
    ssh-agent -s &>"$HOME/.ssh/ssh-agent"
  fi

  eval "$(cat "$HOME/.ssh/ssh-agent")"
fi
