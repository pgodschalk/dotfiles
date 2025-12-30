# shellcheck shell=zsh

if [[ -s "${ZDOTDIR:-${HOME}}/.sources" ]]; then
  source "${ZDOTDIR:-${HOME}}/.sources"
fi
