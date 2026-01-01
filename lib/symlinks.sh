# shellcheck shell=bash
#
# Symlink creation and XDG directory setup

# Default XDG paths for Linux
: "${XDG_CONFIG_HOME:=${HOME}/.config}"
: "${XDG_DATA_HOME:=${HOME}/.local/share}"
: "${XDG_BIN_HOME:=${HOME}/.local/bin}"
: "${ZDOTDIR:=${XDG_CONFIG_HOME}/zsh}"
: "${ZELLIJ_CONFIG_DIR:=${XDG_CONFIG_HOME}/zellij}"

readonly PLATFORM_SUFFIX="_linux"

create_xdg_dirs() {
  msg "${BLUE}Creating XDG directories...${NOFORMAT}"

  local dirs=(
    "${XDG_CONFIG_HOME}"
    "${XDG_DATA_HOME}"
    "${XDG_BIN_HOME}"
    "${ZDOTDIR}"
    "${ZELLIJ_CONFIG_DIR}"
  )

  local dir
  for dir in "${dirs[@]}"; do
    if [[ "${explain:-0}" == "1" ]]; then
      msg "  Would create: ${dir}"
    else
      mkdir --parents "${dir}"
      msg "  Created: ${dir}"
    fi
  done
}

make_link() {
  local src="${1}"
  local dst="${2}"

  if [[ "${explain:-0}" == "1" ]]; then
    msg "  Would link: ${dst} -> ${src}"
    return
  fi

  mkdir --parents "$(dirname "${dst}")"

  if [[ -e "${dst}" || -L "${dst}" ]]; then
    rm --recursive --force "${dst}"
  fi

  ln --symbolic "${src}" "${dst}"
  msg "  Linked: ${dst} -> ${src}"
}

# Directories that need their contents linked (not the directory itself)
# - gnupg: requires write access at runtime
# - git, helix, jj, nano: have platform-specific config files (_linux/_macos)
readonly LINK_CONTENTS_DIRS=(
  git
  gnupg
  helix
  jj
  nano
)

is_link_contents_dir() {
  local name="${1}"
  local dir
  for dir in "${LINK_CONTENTS_DIRS[@]}"; do
    [[ "${name}" == "${dir}" ]] && return 0
  done
  return 1
}

link_directory() {
  local src_dir="${1}"
  local dst_dir="${2}"

  if [[ ! -d "${src_dir}" ]]; then
    msg "${YELLOW}Warning: Source directory not found: ${src_dir}${NOFORMAT}"
    return
  fi

  msg "${BLUE}Linking ${src_dir} -> ${dst_dir}${NOFORMAT}"

  local item name dst_name
  shopt -s nullglob dotglob
  for item in "${src_dir}"/*; do
    [[ -e "${item}" ]] || continue

    name="$(basename "${item}")"

    # Skip macOS-specific files and items that don't work in containers
    # Also skip files that need theme lines stripped (handled by copy_configs)
    if [[ "${name}" == *"_macos"* ]] \
      || [[ "${name}" == ".theme-sync" ]] \
      || [[ "${name}" == ".zed" ]] \
      || [[ "${name}" == "gpg-agent.conf" ]] \
      || [[ "${name}" == "mcp.json" ]] \
      || [[ "${name}" == "macchina.toml" ]] \
      || [[ "${name}" == "config.toml" && "${src_dir}" == *"/helix" ]] \
      || [[ "${name}" == "config_linux.kdl" ]]; then
      continue
    fi

    # Handle Linux-specific files: link as base name
    dst_name="${name}"
    if [[ "${name}" == *"${PLATFORM_SUFFIX}"* ]]; then
      dst_name="${name//_linux/}"
      dst_name="${dst_name//.linux/}"
    fi

    # Directories needing write access: link contents, not directory
    if [[ -d "${item}" ]] && is_link_contents_dir "${dst_name}"; then
      mkdir --parents "${dst_dir}/${dst_name}"
      link_directory "${item}" "${dst_dir}/${dst_name}"
    else
      make_link "${item}" "${dst_dir}/${dst_name}"
    fi
  done
  shopt -u nullglob dotglob
}

link_home_items() {
  local script_dir="${1}"
  local home_src="${script_dir}/HOME"

  if [[ ! -d "${home_src}" ]]; then
    return
  fi

  msg "${BLUE}Linking HOME items...${NOFORMAT}"

  local item name
  shopt -s nullglob dotglob
  for item in "${home_src}"/*; do
    [[ -e "${item}" ]] || continue

    name="$(basename "${item}")"

    # Skip macOS-only items and directories we populate separately
    case "${name}" in
      Library | .orbstack | .config)
        continue
        ;;
    esac

    make_link "${item}" "${HOME}/${name}"
  done
  shopt -u nullglob dotglob

  # Link contents of HOME/.config into XDG_CONFIG_HOME (not the directory)
  if [[ -d "${home_src}/.config" ]]; then
    link_directory "${home_src}/.config" "${XDG_CONFIG_HOME}"
  fi
}

install_prezto() {
  local prezto_dir="${ZDOTDIR}/.zprezto"
  local contrib_dir="${prezto_dir}/contrib"
  local runcoms_dir="${prezto_dir}/runcoms"

  msg "${BLUE}Installing Prezto...${NOFORMAT}"

  if [[ "${explain:-0}" == "1" ]]; then
    msg "  Would clone zprezto to ${prezto_dir}"
    msg "  Would clone prezto-contrib to ${contrib_dir}"
    msg "  Would link runcoms: zshenv, zprofile, zlogin, zlogout"
    return
  fi

  if [[ -d "${prezto_dir}" ]]; then
    msg "  Prezto already installed at ${prezto_dir}"
  else
    git clone --recursive \
      https://github.com/sorin-ionescu/prezto.git "${prezto_dir}"
    msg "  Cloned zprezto to ${prezto_dir}"
  fi

  if [[ -d "${contrib_dir}" ]]; then
    msg "  prezto-contrib already installed at ${contrib_dir}"
  else
    git clone --recursive \
      https://github.com/belak/prezto-contrib.git "${contrib_dir}"
    msg "  Cloned prezto-contrib to ${contrib_dir}"
  fi

  # Link Prezto runcoms
  local runcom
  for runcom in zshenv zprofile zlogin zlogout; do
    make_link "${runcoms_dir}/${runcom}" "${ZDOTDIR}/.${runcom}"
  done
}

copy_configs() {
  local script_dir="${1}"

  msg "${BLUE}Copying configs with theme lines stripped...${NOFORMAT}"

  local src dst

  # macchina.toml - strip theme line
  src="${script_dir}/HOME/.config/macchina/macchina.toml"
  dst="${XDG_CONFIG_HOME}/macchina/macchina.toml"
  if [[ -f "${src}" ]]; then
    if [[ "${explain:-0}" == "1" ]]; then
      msg "  Would copy: ${dst} (theme stripped)"
    else
      mkdir --parents "$(dirname "${dst}")"
      grep --invert-match '^theme = ' "${src}" >"${dst}"
      msg "  Copied: ${dst} (theme stripped)"
    fi
  fi

  # helix/config.toml - strip theme line
  src="${script_dir}/XDG_CONFIG_HOME/helix/config.toml"
  dst="${XDG_CONFIG_HOME}/helix/config.toml"
  if [[ -f "${src}" ]]; then
    if [[ "${explain:-0}" == "1" ]]; then
      msg "  Would copy: ${dst} (theme stripped)"
    else
      mkdir --parents "$(dirname "${dst}")"
      grep --invert-match '^theme = ' "${src}" >"${dst}"
      msg "  Copied: ${dst} (theme stripped)"
    fi
  fi

  # zellij/config_linux.kdl -> config.kdl - strip theme and theme_dir lines
  src="${script_dir}/ZELLIJ_CONFIG_DIR/config_linux.kdl"
  dst="${ZELLIJ_CONFIG_DIR}/config.kdl"
  if [[ -f "${src}" ]]; then
    if [[ "${explain:-0}" == "1" ]]; then
      msg "  Would copy: ${dst} (theme stripped)"
    else
      mkdir --parents "$(dirname "${dst}")"
      grep --invert-match '^theme ' "${src}" \
        | grep --invert-match '^theme_dir ' >"${dst}"
      msg "  Copied: ${dst} (theme stripped)"
    fi
  fi
}

install_symlinks() {
  local script_dir="${1}"

  msg "${GREEN}=== Installing symlinks ===${NOFORMAT}"

  create_xdg_dirs

  link_directory "${script_dir}/ZDOTDIR" "${ZDOTDIR}"
  link_directory "${script_dir}/XDG_CONFIG_HOME" "${XDG_CONFIG_HOME}"
  link_directory "${script_dir}/XDG_BIN_HOME" "${XDG_BIN_HOME}"
  link_directory "${script_dir}/XDG_DATA_HOME" "${XDG_DATA_HOME}"
  link_directory "${script_dir}/ZELLIJ_CONFIG_DIR" "${ZELLIJ_CONFIG_DIR}"

  link_home_items "${script_dir}"
  copy_configs "${script_dir}"
  install_prezto

  msg "${GREEN}Symlinks installed successfully${NOFORMAT}"
}
