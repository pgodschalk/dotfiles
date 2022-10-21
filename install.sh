#!/bin/sh
# Wrapper for Alpine where bash is not immediately available

if ! command -v bash; then
  if command -v apk; then
    if command -v sudo; then
      sudo apk add bash
    else
      apk add bash
    fi
  fi
fi

bash install_bash.sh
