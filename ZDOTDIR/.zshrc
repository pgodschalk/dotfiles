# shellcheck shell=zsh

if [[ -s "${ZDOTDIR:-${HOME}}/.sources" ]]; then
  source "${ZDOTDIR:-${HOME}}/.sources"
fi

if [[ "${DISTRO}" == "macos" ]]; then
  # Use Secretive SSH agent
  export SSH_AUTH_SOCK
  SSH_AUTH_SOCK="${HOME}/Library/Containers"
  SSH_AUTH_SOCK+="/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
fi

if [[ $TERM == "xterm-ghostty" ]] && (( $+commands[macchina] )); then
  macchina
fi
