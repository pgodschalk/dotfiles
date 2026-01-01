# shellcheck shell=bash
#
# Package manager abstraction layer

# These functions must be implemented by distro-specific scripts:
# - pkg_update       Update package lists
# - pkg_install      Install packages
# - pkg_installed    Check if package is installed

install_packages() {
  msg "${GREEN}=== Installing packages ===${NOFORMAT}"

  if [[ "${explain:-0}" == "1" ]]; then
    msg "Would update package lists"
    msg "Would install core packages: ${PACKAGES_CORE[*]}"
    msg "Would install CLI tools: ${PACKAGES_CLI[*]}"
    msg "Would install python3 if missing"
    msg "Would install ruby if missing"
    msg "Would install starship prompt"
    msg "Would install GitHub tools (helix, tspin, delta, eza, etc.)"
    return
  fi

  msg "${BLUE}Updating package lists...${NOFORMAT}"
  pkg_update

  msg "${BLUE}Installing core packages...${NOFORMAT}"
  pkg_install "${PACKAGES_CORE[@]}"

  msg "${BLUE}Installing CLI tools...${NOFORMAT}"
  pkg_install "${PACKAGES_CLI[@]}"

  msg "${BLUE}Installing languages if missing...${NOFORMAT}"
  if ! which python3 &>/dev/null; then
    pkg_install python3
    msg "  Installed python3"
  else
    msg "  python3 already installed"
  fi

  if ! which ruby &>/dev/null; then
    pkg_install ruby
    msg "  Installed ruby"
  else
    msg "  ruby already installed"
  fi

  install_starship
  install_github_tools

  msg "${GREEN}Packages installed successfully${NOFORMAT}"
}

install_starship() {
  if command -v starship &>/dev/null; then
    msg "  Starship already installed"
    return
  fi

  msg "${BLUE}Installing starship...${NOFORMAT}"

  if [[ "${explain:-0}" == "1" ]]; then
    msg "  Would install starship to ${XDG_BIN_HOME}"
    return
  fi

  mkdir --parents "${XDG_BIN_HOME}"
  curl --silent --show-error https://starship.rs/install.sh \
    | sh -s -- --yes --bin-dir "${XDG_BIN_HOME}"
}

# Detect system architecture for GitHub releases
get_arch() {
  local arch
  arch=$(uname --machine)
  case "${arch}" in
    x86_64) echo "x86_64" ;;
    aarch64 | arm64) echo "aarch64" ;;
    *)
      msg "${RED}Unsupported architecture: ${arch}${NOFORMAT}"
      return 1
      ;;
  esac
}

# Get latest version from GitHub API
get_latest_version() {
  local repo="${1}"
  curl --silent --show-error --location \
    "https://api.github.com/repos/${repo}/releases/latest" \
    | grep '"tag_name"' | cut --delimiter '"' --fields 4
}

# Download and extract a GitHub release tarball
install_from_github() {
  local cmd="${1}"
  local repo="${2}"
  local url_pattern="${3}"
  local extract_path="${4:-${cmd}}"
  local format="${5:-tar.gz}"

  if command -v "${cmd}" &>/dev/null; then
    msg "  ${cmd} already installed"
    return
  fi

  msg "  Installing ${cmd}..."

  local arch version url
  arch=$(get_arch) || return 1
  version=$(get_latest_version "${repo}")

  # Replace placeholders in URL pattern
  url="${url_pattern//\{version\}/${version}}"
  url="${url//\{arch\}/${arch}}"

  mkdir --parents "${XDG_BIN_HOME}"

  case "${format}" in
    tar.gz)
      curl --silent --show-error --location "${url}" \
        | tar --extract --gzip --directory "${XDG_BIN_HOME}" "${extract_path}"
      ;;
    tar.xz)
      curl --silent --show-error --location "${url}" \
        | tar --extract --xz --directory "${XDG_BIN_HOME}" "${extract_path}"
      ;;
    zip)
      local tmp_zip
      tmp_zip=$(mktemp)
      curl --silent --show-error --location "${url}" --output "${tmp_zip}"
      unzip -q -o -j "${tmp_zip}" "${extract_path}" -d "${XDG_BIN_HOME}"
      rm --force "${tmp_zip}"
      ;;
    binary)
      curl --silent --show-error --location "${url}" \
        --output "${XDG_BIN_HOME}/${cmd}"
      ;;
  esac

  chmod +x "${XDG_BIN_HOME}/${cmd}"
}

install_github_tools() {
  msg "${BLUE}Installing tools from GitHub...${NOFORMAT}"

  if [[ "${explain:-0}" == "1" ]]; then
    return
  fi

  local arch
  arch=$(get_arch) || return 1

  # bat-extras (shell scripts)
  if ! command -v batgrep &>/dev/null; then
    msg "  Installing bat-extras..."
    local batextras_version
    batextras_version=$(get_latest_version "eth-p/bat-extras")
    local batextras_url="https://github.com/eth-p/bat-extras/releases/download"
    batextras_url="${batextras_url}/${batextras_version}"
    batextras_url="${batextras_url}/bat-extras-${batextras_version#v}.zip"
    local tmp_zip
    tmp_zip=$(mktemp)
    curl --silent --show-error --location "${batextras_url}" \
      --output "${tmp_zip}"
    unzip -q -o -j "${tmp_zip}" "bin/*" -d "${XDG_BIN_HOME}"
    rm --force "${tmp_zip}"
  else
    msg "  bat-extras already installed"
  fi

  # difftastic
  local difft_url="https://github.com/Wilfred/difftastic/releases/download"
  difft_url="${difft_url}/{version}/difft-{arch}-unknown-linux-gnu.tar.gz"
  install_from_github "difft" "Wilfred/difftastic" "${difft_url}" "difft"

  # doggo
  if ! command -v doggo &>/dev/null; then
    msg "  Installing doggo..."
    local doggo_version
    doggo_version=$(get_latest_version "mr-karan/doggo")
    local doggo_url="https://github.com/mr-karan/doggo/releases/download"
    doggo_url="${doggo_url}/${doggo_version}"
    doggo_url="${doggo_url}/doggo_${doggo_version#v}_linux_${arch}.tar.gz"
    curl --silent --show-error --location "${doggo_url}" \
      | tar --extract --gzip --directory "${XDG_BIN_HOME}" doggo
    chmod +x "${XDG_BIN_HOME}/doggo"
  else
    msg "  doggo already installed"
  fi

  # eza
  local eza_url="https://github.com/eza-community/eza/releases/download"
  eza_url="${eza_url}/{version}/eza_{arch}-unknown-linux-gnu.tar.gz"
  install_from_github "eza" "eza-community/eza" "${eza_url}" "eza"

  # git-delta
  if ! command -v delta &>/dev/null; then
    msg "  Installing delta..."
    local delta_version
    delta_version=$(get_latest_version "dandavison/delta")
    local delta_url="https://github.com/dandavison/delta/releases/download"
    local delta_file="delta-${delta_version}-${arch}-unknown-linux-gnu"
    delta_url="${delta_url}/${delta_version}/${delta_file}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp --directory)
    curl --silent --show-error --location "${delta_url}" \
      | tar --extract --gzip --directory "${tmp_dir}"
    mv "${tmp_dir}/${delta_file}/delta" "${XDG_BIN_HOME}/delta"
    chmod +x "${XDG_BIN_HOME}/delta"
    rm --recursive --force "${tmp_dir}"
  else
    msg "  delta already installed"
  fi

  # helix
  if ! command -v hx &>/dev/null; then
    msg "  Installing helix..."
    local helix_version
    helix_version=$(get_latest_version "helix-editor/helix")
    local helix_url="https://github.com/helix-editor/helix/releases/download"
    local helix_file="helix-${helix_version}-${arch}-linux"
    helix_url="${helix_url}/${helix_version}/${helix_file}.tar.xz"
    local tmp_dir
    tmp_dir=$(mktemp --directory)
    curl --silent --show-error --location "${helix_url}" \
      | tar --extract --xz --directory "${tmp_dir}"
    mv "${tmp_dir}/${helix_file}/hx" "${XDG_BIN_HOME}/hx"
    chmod +x "${XDG_BIN_HOME}/hx"
    local runtime_dir="${XDG_CONFIG_HOME}/helix/runtime"
    mkdir --parents "${runtime_dir}"
    cp --recursive "${tmp_dir}/${helix_file}/runtime"/* "${runtime_dir}/"
    rm --recursive --force "${tmp_dir}"
  else
    msg "  helix already installed"
  fi

  # jaq
  local jaq_url="https://github.com/01mf02/jaq/releases/download"
  jaq_url="${jaq_url}/{version}/jaq-{arch}-unknown-linux-gnu"
  install_from_github "jaq" "01mf02/jaq" "${jaq_url}" "jaq" "binary"
  # Rename downloaded binary
  [[ -f "${XDG_BIN_HOME}/jaq-${arch}-unknown-linux-gnu" ]] \
    && mv "${XDG_BIN_HOME}/jaq-${arch}-unknown-linux-gnu" "${XDG_BIN_HOME}/jaq"

  # nanorc (syntax highlighting)
  if [[ ! -d "${XDG_DATA_HOME}/nano" ]]; then
    msg "  Installing nanorc..."
    git clone --quiet --depth 1 \
      https://github.com/scopatz/nanorc.git "${XDG_DATA_HOME}/nano"
  else
    msg "  nanorc already installed"
  fi

  # procs
  if ! command -v procs &>/dev/null; then
    msg "  Installing procs..."
    local procs_version
    procs_version=$(get_latest_version "dalance/procs")
    local procs_url="https://github.com/dalance/procs/releases/download"
    local procs_file="procs-${procs_version}-${arch}-linux"
    procs_url="${procs_url}/${procs_version}/${procs_file}.zip"
    local tmp_zip
    tmp_zip=$(mktemp)
    curl --silent --show-error --location "${procs_url}" --output "${tmp_zip}"
    unzip -q -o "${tmp_zip}" -d "${XDG_BIN_HOME}"
    chmod +x "${XDG_BIN_HOME}/procs"
    rm --force "${tmp_zip}"
  else
    msg "  procs already installed"
  fi

  # ripgrep-all
  if ! command -v rga &>/dev/null; then
    msg "  Installing ripgrep-all..."
    local rga_version
    rga_version=$(get_latest_version "phiresky/ripgrep-all")
    local rga_url="https://github.com/phiresky/ripgrep-all/releases/download"
    local rga_file="ripgrep_all-${rga_version}-${arch}-unknown-linux-musl"
    rga_url="${rga_url}/${rga_version}/${rga_file}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp --directory)
    curl --silent --show-error --location "${rga_url}" \
      | tar --extract --gzip --directory "${tmp_dir}"
    local rga_dir="${tmp_dir}/${rga_file}"
    mv "${rga_dir}/rga" "${XDG_BIN_HOME}/rga"
    mv "${rga_dir}/rga-preproc" "${XDG_BIN_HOME}/rga-preproc"
    chmod +x "${XDG_BIN_HOME}/rga" "${XDG_BIN_HOME}/rga-preproc"
    rm --recursive --force "${tmp_dir}"
  else
    msg "  ripgrep-all already installed"
  fi

  # tailspin (tspin)
  local tspin_url="https://github.com/bensadeh/tailspin/releases/download"
  tspin_url="${tspin_url}/{version}/tailspin-{arch}-unknown-linux-musl.tar.gz"
  install_from_github "tspin" "bensadeh/tailspin" "${tspin_url}" "tspin"

  # tlrc
  local tldr_url="https://github.com/tldr-pages/tlrc/releases/download"
  local tldr_file="tlrc-{version}-{arch}-unknown-linux-musl.tar.gz"
  tldr_url="${tldr_url}/{version}/${tldr_file}"
  install_from_github "tldr" "tldr-pages/tlrc" "${tldr_url}" "tldr"

  # xh
  if ! command -v xh &>/dev/null; then
    msg "  Installing xh..."
    local xh_version
    xh_version=$(get_latest_version "ducaale/xh")
    local xh_url="https://github.com/ducaale/xh/releases/download"
    local xh_file="xh-${xh_version}-${arch}-unknown-linux-musl"
    xh_url="${xh_url}/${xh_version}/${xh_file}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp --directory)
    curl --silent --show-error --location "${xh_url}" \
      | tar --extract --gzip --directory "${tmp_dir}"
    mv "${tmp_dir}/${xh_file}/xh" "${XDG_BIN_HOME}/xh"
    chmod +x "${XDG_BIN_HOME}/xh"
    rm --recursive --force "${tmp_dir}"
  else
    msg "  xh already installed"
  fi

  # yq
  if ! command -v yq &>/dev/null; then
    msg "  Installing yq..."
    local yq_version yq_arch
    yq_version=$(get_latest_version "mikefarah/yq")
    case "${arch}" in
      x86_64) yq_arch="amd64" ;;
      aarch64) yq_arch="arm64" ;;
    esac
    local yq_url="https://github.com/mikefarah/yq/releases/download"
    yq_url="${yq_url}/${yq_version}/yq_linux_${yq_arch}"
    curl --silent --show-error --location "${yq_url}" \
      --output "${XDG_BIN_HOME}/yq"
    chmod +x "${XDG_BIN_HOME}/yq"
  else
    msg "  yq already installed"
  fi

  # zoxide
  if ! command -v zoxide &>/dev/null; then
    msg "  Installing zoxide..."
    local zoxide_version
    zoxide_version=$(get_latest_version "ajeetdsouza/zoxide")
    local zoxide_url="https://github.com/ajeetdsouza/zoxide/releases/download"
    local zoxide_file="zoxide-${zoxide_version}-${arch}-unknown-linux-musl"
    zoxide_url="${zoxide_url}/${zoxide_version}/${zoxide_file}.tar.gz"
    curl --silent --show-error --location "${zoxide_url}" \
      | tar --extract --gzip --directory "${XDG_BIN_HOME}" zoxide
    chmod +x "${XDG_BIN_HOME}/zoxide"
  else
    msg "  zoxide already installed"
  fi
}
