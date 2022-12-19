#!/usr/bin/env bash
# shellcheck disable=SC2034

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v]

Runs maintenance on headless Ubuntu.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  return 0
}

parse_params "$@"
setup_colors

msg "${BLUE}Updating apt${NOFORMAT}"
sudo apt update
sudo apt dist-upgrade --assume-yes
sudo apt autoremove --assume-yes
sudo dpkg --list | grep '^rc ' | cut -d ' ' -f3 | sudo xargs dpkg --purge || true

msg "${BLUE}Updating snap${NOFORMAT}"
sudo snap refresh

msg "${BLUE}Updating composer${NOFORMAT}"
composer global update

msg "${BLUE}Updating AWS CLI${NOFORMAT}"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" --output "/tmp/awscliv2.zip"
cd /tmp || exit
unzip awscliv2.zip
./aws/install --bin-dir "$HOME/.local/bin" --install-dir "$HOME/.local/opt/aws-cli" --update
rm --force /tmp/awscliv2.zip
rm --recursive --force /tmp/aws

msg "${BLUE}Updating OCI CLI${NOFORMAT}"
python3 -m venv "$HOME/.local/lib"
#/env/bin/pip install --upgrade pip
#/env/bin/pip install --upgrade wheel
#/env/bin/pip install --upgrade oci-cli
#/env/bin/pip install --upgrade cx-Oracle

msg "${BLUE}Updating asdf${NOFORMAT}"
asdf update
asdf install nodejs lts
asdf global nodejs lts
asdf install iam-policy-json-to-terraform latest
asdf global iam-policy-json-to-terraform latest

msg "${BLUE}Updating tldr${NOFORMAT}"
tldr --update

msg "${BLUE}Updating dotfile git repositories${NOFORMAT}"
cd "$HOME/.zprezto" || exit
git pull
