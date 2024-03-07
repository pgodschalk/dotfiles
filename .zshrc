# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Source iTerm2 Shell Integration
if [[ -s "${HOME}/.iterm2_shell_integration.zsh" && $TERM_PROGRAM == "iTerm.app" ]]; then
  source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Source Starship
if command -v starship &>/dev/null; then
  if [[ $TERM_PROGRAM == "WarpTerminal" ]]; then
    export STARSHIP_CONFIG="$HOME/.config/starship-warp.toml"
  fi
  eval "$(starship init zsh)"
fi

if [[ $TERM_PROGRAM != "WarpTerminal" ]]; then
  # Brew completions
  if command -v brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
    autoload -Uz compinit
    compinit
  fi

  # Set up ngrok completions
  if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
  fi
fi

# Source Prezto modules depending on current environment
if [[ -s "${HOME}/.zmodules" ]]; then
  source "${HOME}/.zmodules"
fi

if command -v brew &>/dev/null; then
  # Avoid issues with `gpg` as installed via Homebrew.
  # https://stackoverflow.com/a/42265848/96656
  GPG_TTY=$(tty)
  export GPG_TTY
fi

# asdf version manager
if command -v brew &>/dev/null; then
  . $(brew --prefix asdf)/libexec/asdf.sh
else
  . "$HOME/.asdf/asdf.sh"
fi

# Source 1Password plugins
if [[ -f "$HOME/.config/op/plugins.sh" ]]; then
  source "$HOME/.config/op/plugins.sh"
fi

# Add command-not-found to $PATH on macOS
if [[ $DISTRO == "macos" && $TERM_PROGRAM != "WarpTerminal" ]]; then
  HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
  if [ -f "$HB_CNF_HANDLER" ]; then
    source "$HB_CNF_HANDLER";
  fi
fi

# Custom
if [[ -s "${HOME}/.aliases" ]]; then
  source "${HOME}/.aliases"
fi
if [[ -s "${HOME}/.aliases_private" ]]; then
  source "${HOME}/.aliases_private"
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
