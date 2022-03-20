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
eval "$(starship init zsh)"

# Source Zoxide
eval "$(zoxide init zsh)"

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
if [[ -s "${HOME}/.exports" ]]; then
  source "${HOME}/.exports"
fi
if [[ -s "${HOME}/.functions" ]]; then
  source "${HOME}/.functions"
fi
if [[ -s "${HOME}/.aliases_private" ]]; then
  source "${HOME}/.aliases_private"
fi

# Session for Bitwarden CLI
if [[ -s "${HOME}/.bwsession" ]]; then
  source "${HOME}/.bwsession"
fi

# Add OpenJDK to $PATH
if [[ -s "/usr/local/opt/openjdk/bin" ]]; then
  export PATH="/usr/local/opt/openjdk/bin:$PATH"
fi

# Add Google Cloud SDK to $PATH on macOS
if [[ -s "/usr/local/Caskroom/google-cloud-sdk" ]]; then
  source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc
  source /usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
fi

# Add command-not-found to $PATH on macOS
if [[ $DISTRO == "macos" ]]; then
  HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
  if [ -f "$HB_CNF_HANDLER" ]; then
    source "$HB_CNF_HANDLER";
  fi
fi

# This loads nvm
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
