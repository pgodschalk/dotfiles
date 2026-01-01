# shellcheck shell=bash
#
# Detect Linux distribution

detect_distro() {
  if [[ "$(uname --kernel-name)" != "Linux" ]]; then
    die "${RED}Error: This script only supports Linux${NOFORMAT}"
  fi

  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/dev/null
    source /etc/os-release
    DISTRO="${ID}"
    DISTRO_VERSION="${VERSION_ID:-}"

    case "${ID}" in
      ubuntu | debian | linuxmint | pop)
        DISTRO_FAMILY="debian"
        ;;
      fedora | rhel | centos | rocky | alma)
        DISTRO_FAMILY="rhel"
        ;;
      arch | manjaro | endeavouros)
        DISTRO_FAMILY="arch"
        ;;
      opensuse*)
        DISTRO_FAMILY="suse"
        ;;
      *)
        DISTRO_FAMILY="${ID}"
        ;;
    esac
  else
    die \
      "${RED}Error: Cannot detect distribution (no /etc/os-release)${NOFORMAT}"
  fi

  export DISTRO DISTRO_VERSION DISTRO_FAMILY
}

check_distro_supported() {
  local script_dir="${1}"
  local distro_script="${script_dir}/distros/${DISTRO}.sh"

  if [[ ! -f "${distro_script}" ]]; then
    local supported
    supported=$(
      find "${script_dir}/distros/" -name '*.sh' -exec basename {} .sh \; \
        | sort \
        | tr '\n' ' '
    )
    die "${RED}Error: Unsupported distribution: ${DISTRO}${NOFORMAT}
Supported distributions: ${supported}"
  fi

  # shellcheck source=/dev/null
  source "${distro_script}"
}
