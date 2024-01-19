#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

if [[ $OSTYPE == "linux-gnu"* ]]; then
  if grep -q "debian" /etc/os-release; then
    export DISTRO="debian"
  elif grep -q "Arch" /etc/os-release; then
    export DISTRO="arch"
  elif grep -q "rhel" /etc/os-release; then
    export DISTRO="rhel"
  fi
elif [[ $OSTYPE == "darwin"* ]]; then
  export DISTRO="macos"
fi

# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Source iTerm2 Shell Integration
if [[ -s "${HOME}/.iterm2_shell_integration.zsh" ]]; then
  source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Source Starship
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# Source Zoxide
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# Brew completions
if command -v brew &>/dev/null; then
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
if [[ -s "${HOME}/.aliases_private" ]]; then
  source "${HOME}/.aliases_private"
fi
if [[ -s "${HOME}/.exports" ]]; then
  source "${HOME}/.exports"
fi
if [[ -s "${HOME}/.exports_private" ]]; then
  source "${HOME}/.exports_private"
fi
if [[ -s "${HOME}/.functions" ]]; then
  source "${HOME}/.functions"
fi
if [[ -s "${HOME}/.functions_private" ]]; then
  source "${HOME}/.functions_private"
fi
if [[ -s "${HOME}/.sources" ]]; then
  source "${HOME}/.sources"
fi
if [[ -s "${HOME}/.sources_private" ]]; then
  source "${HOME}/.sources_private"
fi

# Add GNU Coreutils to $PATH
if [[ -s "/usr/local/opt/coreutils/libexec/gnubin" ]]; then
  export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
fi

# Add GNU sed to $PATH
if [[ -s "/usr/local/opt/gnu-sed/libexec/gnubin" ]]; then
  export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
fi

# Add Composer packages to $PATH
if command -v composer &>/dev/null; then
  export PATH="$HOME/.composer/vendor/bin:$PATH"
fi

# Add XDG binaries to $PATH
if [[ -s "${HOME}/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH";
fi

# Add OpenJDK to $PATH
if [[ -s "/usr/local/opt/openjdk/bin" ]]; then
  export PATH="/usr/local/opt/openjdk/bin:$PATH"
fi

# Add Google Cloud SDK to $PATH on macOS
if [[ -s "/opt/homebrew/share/google-cloud-sdk/google-cloud-sdk" ]]; then
  source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc"
  source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc"
fi

# Add command-not-found to $PATH on macOS
if [[ $DISTRO == "macos" ]]; then
  HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
  if [ -f "$HB_CNF_HANDLER" ]; then
    source "$HB_CNF_HANDLER";
  fi
fi

# Add dotfiles bin to $PATH
if [[ -s "${HOME}/Code/for/all/dotfiles/bin" ]]; then
  export PATH="$HOME/Code/for/all/dotfiles/bin:$PATH";
fi

# Add GNU sed to $PATH
if [[ -s "/opt/homebrew/opt/gnu-sed/libexec/gnubin" ]]; then
  export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
fi

# Add postgres to $PATH
if [[ -s "/opt/homebrew/opt/postgresql@15/bin" ]]; then
  export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
fi

# SSH agent
if [ -z "$SSH_AUTH_SOCK" ]; then
  # Check for a currently running instance of the agent
  RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
  if [ "$RUNNING_AGENT" = "0" ]; then
    # Launch a new instance of the agent
    ssh-agent -s &> $HOME/.ssh/ssh-agent
  fi
  eval $(cat $HOME/.ssh/ssh-agent)
fi

# asdf version manager
if command -v brew &>/dev/null; then
  . $(brew --prefix asdf)/libexec/asdf.sh
else
  . "$HOME/.asdf/asdf.sh"
fi

# Set up golang
if [[ -f "$HOME/.asdf/plugins/golang/set-env.zsh" ]]; then
  . ~/.asdf/plugins/golang/set-env.zsh
fi

# Set up ngrok completions
if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi

# Set up direnv
eval "$(direnv hook zsh)"

# Ensure MacGPG is loaded before brew's gnupg
if [[ -f "/usr/local/MacGPG2/bin/gpg" ]]; then
  export PATH=/usr/local/MacGPG2/bin:$PATH
fi

# Source 1Password plugins
if [[ -f "$HOME/.config/op/plugins.sh" ]]; then
  source "$HOME/.config/op/plugins.sh"
fi
