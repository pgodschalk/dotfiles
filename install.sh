#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

# Personal-dotfiles entrypoint for dev containers. The dotfiles integration
# clones this repo and runs this script from the repo root. We bootstrap into
# ~/.local/bin: chezmoi (to apply the dotfiles), a curated set of
# general-purpose CLI tools via mise, and a few more that aren't in mise's
# registry directly from their GitHub releases. Language runtimes, LSPs, and
# linters are intentionally NOT installed here — those belong in the dev
# container definition. Anything still missing degrades gracefully behind its
# `(( $+commands[…] ))` guard, so it just disables that integration.

bin_dir="${HOME}/.local/bin"
repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"

# General-purpose niceties available in mise's registry (native binaries — no
# language runtimes; claude-code and helix install standalone).
mise_tools=(
  starship eza bat fd fzf ripgrep zoxide delta difftastic
  jaq yq xh doggo zellij gh glab jj helix claude
)

fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl --fail --silent --show-error --location "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget --quiet --output-document=- "$1"
  else
    echo "install.sh: need curl or wget to download ${1}." >&2
    return 1
  fi
}

# GitHub API GET. Uses a token when present to dodge the 60/hr anonymous limit
# (Codespaces sets GITHUB_TOKEN; mise honours it too). Only for api.github.com —
# asset downloads go through fetch(), which never forwards the token off-host.
gh_api() {
  local token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
  if [ -n "${token}" ] && command -v curl >/dev/null 2>&1; then
    curl --fail --silent --show-error --location \
      --header "Authorization: Bearer ${token}" "$1"
  elif [ -n "${token}" ] && command -v wget >/dev/null 2>&1; then
    wget --quiet --output-document=- \
      --header "Authorization: Bearer ${token}" "$1"
  else
    fetch "$1"
  fi
}

# install_release_bin <owner/repo> <binary>: drop a prebuilt binary from the
# project's latest GitHub release into ~/.local/bin, matching this OS/arch.
# Best-effort — for niceties mise's registry doesn't carry (e.g. wrong arch
# metadata, or not registered at all).
install_release_bin() {
  local repo="$1" binary="$2"
  command -v "${binary}" >/dev/null 2>&1 && return 0

  local arch_re os_re
  case "$(uname -m)" in
    aarch64 | arm64) arch_re='aarch64|arm64' ;;
    x86_64 | amd64) arch_re='x86_64|amd64' ;;
    *) return 0 ;;
  esac
  case "$(uname -s)" in
    Linux) os_re='linux' ;;
    Darwin) os_re='darwin|apple|macos' ;;
    *) return 0 ;;
  esac

  local assets
  assets="$(gh_api "https://api.github.com/repos/${repo}/releases/latest" \
    | grep -oiE 'https://[^"]+' | grep -i '/releases/download/' \
    | grep -iE "(${arch_re})" | grep -iE "(${os_re})")"

  local tmp url found
  tmp="$(mktemp -d)"
  url="$(printf '%s\n' "${assets}" \
    | grep -iE '\.(tar\.gz|tgz|tar\.xz|zip)$' | head -n 1)"
  if [ -n "${url}" ]; then
    if fetch "${url}" >"${tmp}/asset"; then
      case "${url}" in
        *.zip) (cd "${tmp}" && unzip -q asset) ;;
        *) tar -C "${tmp}" -xf "${tmp}/asset" ;;
      esac
      found="$(find "${tmp}" -type f -name "${binary}" | head -n 1)"
      [ -n "${found}" ] && install -m 0755 "${found}" "${bin_dir}/${binary}"
    fi
  else
    # No archive — try a raw binary asset (e.g. miniserve ships bare binaries).
    url="$(printf '%s\n' "${assets}" \
      | grep -viE '\.(sha256|sha512|md5|asc|sig|deb|rpm|pkg|txt|tar\.gz|tgz|tar\.xz|zip)$' \
      | head -n 1)"
    if [ -n "${url}" ] && fetch "${url}" >"${tmp}/${binary}"; then
      install -m 0755 "${tmp}/${binary}" "${bin_dir}/${binary}"
    fi
  fi
  rm -rf "${tmp}"

  if [ -x "${bin_dir}/${binary}" ] || command -v "${binary}" >/dev/null 2>&1; then
    echo "install.sh: installed ${binary} from ${repo}." >&2
  else
    echo "install.sh: could not install ${binary} from ${repo} (skipped)." >&2
  fi
}

# clone_private_repo <owner/repo> <dest>: shallow-clone a private repo, best
# effort. Auth order: DOTFILES_THEME_PAT (Codespaces) → SSH/forwarded agent →
# gh. Non-fatal — a failure just means the theme falls back to built-ins.
clone_private_repo() {
  local repo="$1" dest="$2" token="${3:-}"
  [ -e "${dest}/.git" ] && return 0
  command -v git >/dev/null 2>&1 || return 0
  mkdir -p "$(dirname -- "${dest}")"

  if [ -n "${token}" ] && git clone --depth 1 --quiet \
    "https://x-access-token:${token}@github.com/${repo}.git" \
    "${dest}" 2>/dev/null; then
    return 0
  fi
  if GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new" \
    git clone --depth 1 --quiet "git@github.com:${repo}.git" "${dest}" \
    2>/dev/null; then
    return 0
  fi
  if command -v gh >/dev/null 2>&1 \
    && gh repo clone "${repo}" "${dest}" -- --depth 1 2>/dev/null; then
    return 0
  fi
  echo "install.sh: could not clone ${repo} (theme falls back to built-in)." >&2
}

chezmoi="$(command -v chezmoi || true)"
if [ -z "${chezmoi}" ]; then
  echo "install.sh: chezmoi not found; bootstrapping it into ${bin_dir}" >&2
  sh -c "$(fetch get.chezmoi.io)" -- -b "${bin_dir}"
  chezmoi="${bin_dir}/chezmoi"
fi

if [ ! -x "${chezmoi}" ]; then
  echo "install.sh: chezmoi is not available at '${chezmoi}'." >&2
  exit 1
fi

# .chezmoiroot redirects the source to home/; secret-backed configs resolve from
# env vars, then `op`, then empty (see .chezmoitemplates/secret.tmpl).
# DOTFILES_DEVCONTAINER makes the mise config skip its language toolchains —
# those belong in the dev container definition (see mise-config.tmpl).
DOTFILES_DEVCONTAINER=1 "${chezmoi}" init --apply --source="${repo_root}"

# CLI niceties via mise, into a dedicated drop-in config so the language list in
# mise's main config is never touched. Best-effort.
mise="$(command -v mise || true)"
if [ -z "${mise}" ]; then
  echo "install.sh: mise not found; bootstrapping it into ${bin_dir}" >&2
  fetch https://mise.run | sh || echo "install.sh: mise bootstrap failed." >&2
  mise="${bin_dir}/mise"
fi

if [ -x "${mise}" ]; then
  conf_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/mise/conf.d"
  mkdir -p "${conf_dir}"
  {
    echo "[tools]"
    for tool in "${mise_tools[@]}"; do
      echo "${tool} = \"latest\""
    done
  } >"${conf_dir}/devcontainer.toml"

  "${mise}" install "${mise_tools[@]/%/@latest}" \
    || echo "install.sh: some mise tools failed to install (non-fatal)." >&2
fi

# Niceties not (cleanly) in mise's registry, straight from their GitHub releases.
install_release_bin tldr-pages/tlrc tldr || true
install_release_bin dalance/procs procs || true
install_release_bin bensadeh/tailspin tspin || true
install_release_bin Macchina-CLI/macchina macchina || true
install_release_bin svenstaro/miniserve miniserve || true

# bat-extras: standalone bash scripts (batgrep, batman, batpipe, batwatch,
# batdiff), shipped as a release zip. Not arch-specific; needs `bat` at runtime.
if ! command -v batgrep >/dev/null 2>&1; then
  be_url="$(gh_api https://api.github.com/repos/eth-p/bat-extras/releases/latest \
    | grep -oiE 'https://[^"]+\.zip' | head -n 1)"
  if [ -n "${be_url}" ]; then
    be_tmp="$(mktemp -d)"
    if fetch "${be_url}" >"${be_tmp}/bat-extras.zip" \
      && (cd "${be_tmp}" && unzip -q bat-extras.zip); then
      find "${be_tmp}" -type f -path '*/bin/bat*' \
        -exec install -m 0755 {} "${bin_dir}/" \;
      echo "install.sh: installed bat-extras." >&2
    fi
    rm -rf "${be_tmp}"
  fi
fi

# Dracula Pro themes (private repos). The Linux theme-sync uses these when
# present and falls back to built-in themes otherwise (see dot_theme-sync).
# Per-repo tokens (fine-grained PATs) take precedence; DOTFILES_THEME_PAT is a
# shared fallback (e.g. one classic PAT spanning both).
extras_dir="${HOME}/Developer/for/me/dracula-pro-extras"
clone_private_repo pgodschalk/dracula-pro-extras "${extras_dir}" \
  "${DRACULA_PRO_EXTRAS_PAT:-${DOTFILES_THEME_PAT:-}}"
clone_private_repo dracula-pro/dracula-pro "${HOME}/Developer/build/dracula-pro" \
  "${DRACULA_PRO_PAT:-${DOTFILES_THEME_PAT:-}}"

# eza theme files → where EZA_CONFIG_DIR (dark/light) expects them.
if [ -d "${extras_dir}/themes/eza" ]; then
  for pair in dark:pro light:alucard; do
    eza_src="${extras_dir}/themes/eza/${pair#*:}.yml"
    [ -f "${eza_src}" ] || continue
    mkdir -p "${HOME}/.config/eza/${pair%%:*}"
    cp -f "${eza_src}" "${HOME}/.config/eza/${pair%%:*}/theme.yml"
  done
fi

# bat themes from dracula-pro (+ cache) so BAT_THEME="Dracula Pro" resolves.
dpro_sublime="${HOME}/Developer/build/dracula-pro/dracula-pro/themes/sublime"
if [ -d "${dpro_sublime}" ] && command -v bat >/dev/null 2>&1; then
  bat_themes="$(bat --config-dir)/themes"
  mkdir -p "${bat_themes}"
  ln -sf "${dpro_sublime}/Dracula Pro.tmTheme" "${bat_themes}/"
  ln -sf "${dpro_sublime}/Dracula Pro (Alucard).tmTheme" "${bat_themes}/"
  bat cache --build >/dev/null 2>&1 || true
fi
