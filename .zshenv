# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi
. "$HOME/.cargo/env"

if [[ -s "${HOME}/.exports" ]]; then
  source "${HOME}/.exports"
fi
if [[ -s "${HOME}/.exports_private" ]]; then
  source "${HOME}/.exports_private"
fi
