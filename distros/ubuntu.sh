# shellcheck shell=bash
#
# Ubuntu-specific package installation

# Package lists (used by lib/packages.sh)
# shellcheck disable=SC2034
readonly PACKAGES_CORE=(
  curl
  git
  unzip
  wget
  zsh
)

# shellcheck disable=SC2034
readonly PACKAGES_CLI=(
  aspell
  bat
  bc
  chafa
  fd-find
  fzf
  jq
  nano
  pigz
  ripgrep
)

pkg_update() {
  if [[ "${EUID}" -eq 0 ]]; then
    apt-get update --quiet --quiet
  else
    sudo apt-get update --quiet --quiet
  fi
}

pkg_install() {
  local packages=("${@}")

  if [[ "${EUID}" -eq 0 ]]; then
    DEBIAN_FRONTEND=noninteractive \
      apt-get install --yes --quiet --quiet "${packages[@]}"
  else
    sudo DEBIAN_FRONTEND=noninteractive \
      apt-get install --yes --quiet --quiet "${packages[@]}"
  fi
}

pkg_installed() {
  dpkg --list "${1}" &>/dev/null
}
