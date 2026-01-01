#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

usage() {
  cat >&2 <<EOF
Usage: $(basename "${0}") [options]

Installs dotfiles and dependencies. Intended for use in a devcontainer.

Options:
  -h, --help          Print this help and exit
  -v, --verbose       Print script debug info
  -e, --explain       Dry-run mode (show what would happen)
  --no-color          Disable colored output

  --all               Run all phases (default)
  --packages-only     Only install packages
  --symlinks-only     Only create symlinks
  --shell-only        Only configure shell
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m'
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    ORANGE='\033[0;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    YELLOW='\033[1;33m'
  else
    NOFORMAT=''
    RED=''
    GREEN=''
    ORANGE=''
    BLUE=''
    PURPLE=''
    CYAN=''
    YELLOW=''
  fi
  # shellcheck disable=SC2034
  readonly NOFORMAT RED GREEN ORANGE BLUE PURPLE CYAN YELLOW
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local message="${1}"
  local code="${2:-1}"
  msg "${message}"
  exit "${code}"
}

parse_params() {
  # Defaults
  explain=0
  do_packages=0
  do_symlinks=0
  do_shell=0
  do_all=1

  while :; do
    case "${1-}" in
      -e | --explain) explain=1 ;;
      -h | --help) usage ;;
      -v | --verbose) set -x ;;
      --no-color) NO_COLOR=1 ;;
      --all) do_all=1 ;;
      --packages-only)
        do_packages=1
        do_all=0
        ;;
      --symlinks-only)
        do_symlinks=1
        do_all=0
        ;;
      --shell-only)
        do_shell=1
        do_all=0
        ;;
      -?*) die "Unknown option: ${1}" ;;
      *) break ;;
    esac
    shift
  done

  if [[ "${do_all}" == "1" ]]; then
    do_packages=1
    do_symlinks=1
    do_shell=1
  fi

  export explain do_packages do_symlinks do_shell
  return 0
}

configure_shell() {
  msg "${GREEN}=== Configuring shell ===${NOFORMAT}"

  if [[ "${explain:-0}" == "1" ]]; then
    msg "Would set zsh as default shell"
    msg "Would configure ZDOTDIR in /etc/zsh/zshenv"
    return
  fi

  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ -n "${zsh_path}" ]]; then
    msg "${BLUE}Setting zsh as default shell...${NOFORMAT}"

    if [[ "${EUID}" -eq 0 ]]; then
      chsh --shell "${zsh_path}"
    else
      sudo chsh --shell "${zsh_path}" "${USER}"
    fi
  fi

  local zshenv="/etc/zsh/zshenv"
  local zdotdir_line
  zdotdir_line="export ZDOTDIR=\"\${XDG_CONFIG_HOME:-\${HOME}/.config}/zsh\""

  msg "${BLUE}Configuring ZDOTDIR...${NOFORMAT}"

  if [[ "${EUID}" -eq 0 ]]; then
    mkdir --parents "$(dirname "${zshenv}")"
    if ! grep --quiet "ZDOTDIR" "${zshenv}" 2>/dev/null; then
      echo "${zdotdir_line}" >>"${zshenv}"
    fi
  else
    sudo mkdir --parents "$(dirname "${zshenv}")"
    if ! grep --quiet "ZDOTDIR" "${zshenv}" 2>/dev/null; then
      echo "${zdotdir_line}" | sudo tee --append "${zshenv}" >/dev/null
    fi
  fi

  msg "${GREEN}Shell configured successfully${NOFORMAT}"
}

print_summary() {
  msg ""
  msg "${GREEN}=== Installation complete ===${NOFORMAT}"
  msg ""
  msg "Distribution: ${DISTRO} (${DISTRO_FAMILY})"
  msg "ZDOTDIR: ${ZDOTDIR}"
  msg "XDG_CONFIG_HOME: ${XDG_CONFIG_HOME}"
  msg ""
  msg "Start a new shell or run: exec zsh"
}

main() {
  parse_params "${@}"
  setup_colors

  msg "${GREEN}=== Dotfiles Installer ===${NOFORMAT}"
  msg ""

  # shellcheck source=lib/distro.sh
  source "${SCRIPT_DIR}/lib/distro.sh"
  # shellcheck source=lib/symlinks.sh
  source "${SCRIPT_DIR}/lib/symlinks.sh"
  # shellcheck source=lib/packages.sh
  source "${SCRIPT_DIR}/lib/packages.sh"

  detect_distro
  check_distro_supported "${SCRIPT_DIR}"

  msg "Detected: ${DISTRO} (${DISTRO_FAMILY})"
  msg ""

  if [[ "${do_packages}" == "1" ]]; then
    install_packages
    msg ""
  fi

  if [[ "${do_symlinks}" == "1" ]]; then
    install_symlinks "${SCRIPT_DIR}"
    msg ""
  fi

  if [[ "${do_shell}" == "1" ]]; then
    configure_shell
    msg ""
  fi

  if [[ "${explain:-0}" != "1" ]]; then
    print_summary
  fi
}

main "${@}"
