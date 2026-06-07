#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# Personal-dotfiles entrypoint for dev containers. The dotfiles integration
# clones this repo and runs this script from the repo root. The container is
# assumed to already provide every binary we need; the one exception is chezmoi
# itself, which we bootstrap into ~/.local/bin when it is missing.

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"

chezmoi="$(command -v chezmoi || true)"
if [ -z "${chezmoi}" ]; then
  bin_dir="${HOME}/.local/bin"
  echo "install.sh: chezmoi not found; bootstrapping it into ${bin_dir}" >&2
  if command -v curl >/dev/null 2>&1; then
    sh -c "$(curl --fail --silent --show-error --location get.chezmoi.io)" \
      -- -b "${bin_dir}"
  elif command -v wget >/dev/null 2>&1; then
    sh -c "$(wget --quiet --output-document=- get.chezmoi.io)" \
      -- -b "${bin_dir}"
  else
    echo "install.sh: need curl or wget to bootstrap chezmoi." >&2
    exit 1
  fi
  chezmoi="${bin_dir}/chezmoi"
fi

if [ ! -x "${chezmoi}" ]; then
  echo "install.sh: chezmoi is not available at '${chezmoi}'." >&2
  exit 1
fi

# .chezmoiroot redirects the source to home/; secret-backed configs resolve from
# env vars, then `op`, then empty (see .chezmoitemplates/secret.tmpl).
exec "${chezmoi}" init --apply --source="${repo_root}"
