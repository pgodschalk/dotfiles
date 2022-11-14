#!/usr/bin/env bash
# shellcheck disable=SC1036,SC1058,SC1072,SC1073,SC2034,SC2037

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v]

Installs dotfiles and any dependencies.

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

DIFF_SO_FANCY_VERSION=1.4.3
DOGGO_VERSION=0.1.0

### Basic toolchain dependencies
if command -v sudo &> /dev/null; then
  sudo -v
  PKG_INSTALL="sudo"
else
  PKG_INSTALL=""
fi

if command -v apt-get &> /dev/null; then
  bash -c "$PKG_INSTALL apt-get update"
  PKG_INSTALL="$PKG_INSTALL apt-get --assume-yes install"
elif command -v dnf &> /dev/null; then
  PKG_INSTALL="$PKG_INSTALL dnf --assumeyes install"
elif command -v yum &> /dev/null; then
  PKG_INSTALL="$PKG_INSTALL yum --assumeyes install"
elif command -v apk &> /dev/null; then
  bash -c "$PKG_INSTALL apk update"
  PKG_INSTALL="$PKG_INSTALL apk add"
elif command -v brew &> /dev/null; then
  PKG_INSTALL="brew install"
elif command -v pacman &> /dev/null; then
  bash -c "$PKG_INSTALL pacman --sync --refresh --refresh"
  PKG_INSTALL="$PKG_INSTALL pacman --noconfirm --sync"
elif command -v yum &> /dev/null; then
  PKG_INSTALL="$PKG_INSTALL yum --assumeyes install"
elif command -v zypper &> /dev/null; then
  bash -c "$PKG_INSTALL zypper refresh"
  PKG_INSTALL="$PKG_INSTALL zypper --non-interactive install"
fi

install() {
  bash -c "$PKG_INSTALL $1"
}

# zsh
if ! command -v zsh &> /dev/null; then
  install zsh || :

  if command -v chsh &> /dev/null; then
    chsh -s /bin/zsh
  fi
fi

# bat; better cat: https://github.com/sharkdp/bat
if ! command -v bat &> /dev/null; then
  install bat || :
fi

# command-not-found
if command -v brew &> /dev/null; then
  brew tap homebrew/command-not-found
fi
install command-not-found || :
if command -v apt-get &> /dev/null; then
  if command -v sudo &> /dev/null; then
    sudo apt-get update
  else
    apt-get update
  fi
fi

# curl
if ! command -v curl &> /dev/null; then
  install curl || :
fi

# diff-so-fancy; better diff: https://github.com/so-fancy/diff-so-fancy
if ! command -v diff-so-fancy &> /dev/null; then
  if command -v snap &> /dev/null; then
    sudo snap install diff-so-fancy
  elif command -v brew &> /dev/null; then
    brew install diff-so-fancy
  else
    if ! command -v curl &> /dev/null; then
      install curl
    fi
    mkdir --parents "$HOME/.local/bin"
    curl --location --output "$HOME/.local/bin/diff-so-fancy" \
      "https://github.com/so-fancy/diff-so-fancy/releases/download/v$DIFF_SO_FANCY_VERSION/diff-so-fancy"
  fi
fi

# diffstat; for git-divergence
if ! command -v diffstat &> /dev/null; then
  install diffstat || :
fi

# dig; for determining own ip
if ! command -v dig; then
  if command -v apt-get &> /dev/null; then
    export DEBIAN_FRONTEND=noninteractive
    install dnsutils || :
  elif command -v dnf &> /dev/null; then
    install bind-utils || :
  elif command -v apk &> /dev/null; then
    install bind-tools || :
  elif command -v yum &> /dev/null; then
    install bind-utils || :
  elif command -v zypper &> /dev/null; then
    install bind-utils || :
  else
    install bind || :
  fi
fi

# doggo; dns client: https://doggo.mrkaran.dev
if ! command -v doggo &> /dev/null; then
  if command -v snap &> /dev/null; then
    sudo snap install doggo
  elif command -v brew &> /dev/null; then
    install doggo || :
  elif command -v pacman &> /dev/null; then
    install doggo || :
  else
    if [[ $(uname -m) == "x86_64" ]]; then
      curl --location --output /tmp/doggo.tar.gz \
        "https://github.com/mr-karan/doggo/releases/download/v$DOGGO_VERSION/doggo_${DOGGO_VERSION}_linux_amd64.tar.gz"
      cd /tmp || exit
      tar --gzip --extract --file=/tmp/doggo.tar.gz
      cp /tmp/doggo "$HOME/.local/bin/doggo"

      if command -v fish &> /dev/null; then
        mkdir --parents "$HOME/.config/fish/completions"
        cp /tmp/completions/doggo.fish "$HOME/.config/fish/completions/doggo.fish"
      fi

      if command -v zsh &> /dev/null; then
        mkdir --parents "$HOME/.local/share/zsh/vendor-completions"
        cp /tmp/completions/doggo.zsh "$HOME/.local/share/zsh/vendor-completions/doggo.zsh"
      fi
    elif [[ "$(uname -m)" == "aarch64" ]]; then
      curl --location --output /tmp/doggo.tar.gz \
        "https://github.com/mr-karan/doggo/releases/download/v$DOGGO_VERSION/doggo_${DOGGO_VERSION}_linux_arm64.tar.gz"
      cd /tmp || exit
      tar --gzip --extract --file=/tmp/doggo.tar.gz
      cp /tmp/doggo "$HOME/.local/bin/doggo"

      if command -v fish &> /dev/null; then
        mkdir --parents "$HOME/.config/fish/completions"
        cp /tmp/completions/doggo.fish "$HOME/.config/fish/completions/doggo.fish"
      fi

      if command -v zsh &> /dev/null; then
        mkdir --parents "$HOME/.local/share/zsh/vendor-completions"
        cp /tmp/completions/doggo.zsh "$HOME/.local/share/zsh/vendor-completions/doggo.zsh"
      fi
    fi
  fi
fi

# exa; ls replacement: https://github.com/ogham/exa
if ! command -v exa &> /dev/null; then
  install exa || :
fi

# git
if ! command -v git &> /dev/null; then
  install git || :
fi

# gzip
if ! command -v gzip &> /dev/null; then
  install gzip || :
fi

# httpie
if ! command -v http &> /dev/null; then
  install httpie || :
fi

# iterm shell integration
if ! command -v it2copy &> /dev/null; then
  if ! command -v curl &> /dev/null; then
    install curl
  fi
  if ! command -v hostname &> /dev/null; then
    if command -v dnf &> /dev/null; then
      install hostname
    fi
    if command -v yum &> /dev/null; then
      install hostname
    fi
  fi

  if command -v bash; then
    curl --location \
      https://iterm2.com/shell_integration/install_shell_integration.sh | bash
  fi

  for cmd in imgcat imgls it2attention it2check it2copy it2dl it2getvar it2setcolor it2setkeylabel it2ul it2universion; do
    curl -sfLo "$HOME/.local/bin/$cmd" "https://iterm2.com/utilities/$cmd"
    chmod a+x "$HOME/.local/bin/$cmd"
  done

  if command -v bash; then
    curl --location --output "$HOME/.iterm2_shell_integration.bash" \
      https://iterm2.com/shell_integration/bash
    chmod a+x "$HOME/.iterm2_shell_integration.bash"
  fi
  if command -v fish; then
    curl --location --output "$HOME/.iterm2_shell_integration.fish" \
      https://iterm2.com/shell_integration/fish
    chmod a+x "$HOME/.iterm2_shell_integration.fish"
  fi
  if command -v tcsh; then
    curl --location --output "$HOME/.iterm2_shell_integration.tcsh" \
      https://iterm2.com/shell_integration/tcsh
    chmod a+x "$HOME/.iterm2_shell_integration.tcsh"
  fi
  if command -v zsh; then
    curl --location --output "$HOME/.iterm2_shell_integration.zsh" \
      https://iterm2.com/shell_integration/zsh
    chmod a+x "$HOME/.iterm2_shell_integration.zsh"
  fi
fi

# neovim; better vim
if ! command -v nvim &> /dev/null; then
  if command -v dnf &> /dev/null; then
    install epel-release
  fi
  if command -v yum &> /dev/null; then
    install epel-release
  fi
  install neovim || :

  if command -v nvim &> /dev/null; then
    mkdir --parents "$HOME/.config/nvim"
    ln -fs "$script_dir/.config/nvim/init.vim" \
      "$HOME/.config/nvim/init.vim"
  fi
fi

# nano
if ! command -v nano &> /dev/null; then
  install nano || :
fi

# openssl
if ! command -v openssl &> /dev/null; then
  install openssl || :
fi

# pigz
if ! command -v pigz &> /dev/null; then
  install pigz || :
fi

# rg
if ! command -v rg &> /dev/null; then
  install ripgrep || :
fi

# ps
if ! command -v ps &> /dev/null; then
  if command -v apt-get &> /dev/null; then
    install procps || :
  fi
fi

# python; for gn
if ! command -v python &> /dev/null; then
  if command -v dnf &> /dev/null; then
    install python || :
  elif command -v yum &> /dev/null; then
    install python || :
  elif command -v pacman &> /dev/null; then
    install python || :
  else
    install python3 || :

    if command -v apt-get &> /dev/null; then
      install python-is-python3 || :
    fi
  fi
fi

  if ! command -v python &> /dev/null; then
    if command -v python3 &> /dev/null; then
      if command -v sudo &> /dev/null; then
        sudo ln -s /usr/bin/python3 /usr/bin/python
      else
        ln -s /usr/bin/python3 /usr/bin/python
      fi
    fi
  fi

# ruby; for git-whodoneit
if ! command -v ruby &> /dev/null; then
  install ruby || :
fi

# starship; prompt: https://starship.rs
if command -v brew &> /dev/null; then
  install starship || :
else
  curl --silent --show-error https://starship.rs/install.sh \
    --output "$script_dir/starship.sh"
  chmod a+x "$script_dir/starship.sh"
  "$script_dir/starship.sh" --yes
  rm -f "$script_dir/starship.sh"
fi

# thefuck; error correction: https://github.com/nvbn/thefuck
if command -v apt-get &> /dev/null; then
  install thefuck || :
elif command -v dnf &> /dev/null; then
  if command -v pip &> /dev/null; then
    pip install --user thefuck
  fi
elif command -v yum &> /dev/null; then
  if command -v pip &> /dev/null; then
    pip install --user thefuck
  fi
elif command -v apk &> /dev/null; then
  if command -v pip &> /dev/null; then
    pip install --user thefuck
  fi
elif command -v brew &> /dev/null; then
  install thefuck || :
elif command -v pacman &> /dev/null; then
  install thefuck || :
elif command -v yum &> /dev/null; then
  if command -v pip &> /dev/null; then
    pip install --user thefuck
  fi
elif command -v zypper &> /dev/null; then
  if command -v pip &> /dev/null; then
    pip install --user thefuck
  fi
fi

# tldr; simple man pages: https://tldr.sh
if ! command -v tldr &> /dev/null; then
  install tldr || :
fi
if command -v tldr &> /dev/null; then
  tldr --update
fi

# zopfli
if ! command -v zopfli &> /dev/null; then
  install zopfli || :
fi

# zoxide: fuzzy cd: https://github.com/ajeetdsouza/zoxide
if ! command -v z &> /dev/null; then
  install zoxide || :
fi

### Dotfiles

ln -fs "$script_dir/.aliases" "$HOME/.aliases"
touch "$HOME/.aliases_private"
chmod 600 "$HOME/.aliases_private"

if command -v composer &> /dev/null; then
  composer global require "squizlabs/php_codesniffer=*" --dev
  mkdir --parents "$HOME/.config/composer/vendor/squizlabs/php_codesniffer"
  ln -s "$script_dir/.config/composer/vendor/squizlabs/php_codesniffer/CodeSniffer.conf" \
    "$HOME/.config/composer/vendor/squizlabs/php_codesniffer"
fi

if command -v curl &> /dev/null; then
  ln -fs "$script_dir/.curlrc" "$HOME/.curlrc"
fi

ln -fs "$script_dir/.exports" "$HOME/.exports"
touch "$HOME/.exports_private"
chmod 600 "$HOME/.exports_private"
ln -fs "$script_dir/.functions" "$HOME/.functions"

if command -v git &> /dev/null; then
  ln -fs "$script_dir/.gitconfig" "$HOME/.gitconfig"
  ln -fs "$script_dir/.gitignore_global" \
    "$HOME/.gitignore_global"
fi

if command -v gpg &> /dev/null; then
  mkdir --parents "$HOME/.gnupg"
  ln -fs "$script_dir/.gnupg/gpg-agent.conf" \
    "$HOME/.gnupg/gpg-agent.conf"
  ln -fs "$script_dir/.gnupg/gpg.conf" \
    "$HOME/.gnupg/gpg.conf"
fi

ln -fs "$script_dir/.hushlogin" "$HOME/.hushlogin"
ln -fs "$script_dir/.inputrc" "$HOME/.inputrc"

if command -v nano &> /dev/null; then
  ln -fs "$script_dir/.nanorc" "$HOME/.nanorc"
fi

if command -v screen &> /dev/null; then
  ln -fs "$script_dir/.screenrc" "$HOME/.screenrc"
fi

if command -v ssh &> /dev/null; then
  mkdir --parents "$HOME/.ssh"
  ln -fs "$script_dir/.ssh/config" "$HOME/.ssh/config"
  touch "$HOME/.ssh/config-home"
  touch "$HOME/.ssh/config-mozard"
  touch "$HOME/.ssh/config-mozard-local"
fi

if command -v wget &> /dev/null; then
  ln -fs "$script_dir/.wgetrc" "$HOME/.wgetrc"
fi

# Zprezto installation
if command -v zsh &> /dev/null; then
  if command -v git &> /dev/null; then
    git clone --recurse-submodules https://github.com/sorin-ionescu/prezto \
      "$HOME/.zprezto"
    git clone --recurse-submodules https://github.com/belak/prezto-contrib \
      "$HOME/.zprezto/contrib"

    for rcfile in zlogin zlogout zprofile zshenv; do
      ln -s "${ZDOTDIR:-$HOME}/.zprezto/${rcfile}" "${ZDOTDIR:-$HOME}/.${rcfile}"
    done

    ln -fs "$script_dir/.zmodules" "$HOME/.zmodules"
    ln -fs "$script_dir/.zpreztorc" "$HOME/.zpreztorc"
    ln -fs "$script_dir/.zshrc" "$HOME/.zshrc"
  fi
fi

msg "${BLUE}Done!${NOFORMAT}"
