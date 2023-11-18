#!/bin/bash
if ! which cargo >/dev/null 2>/dev/null; then 
  echo "Cargo is not installed."
  echo "Please install Cargo before running this script"
  exit 1  
fi

cli_utilities=(
 "fd-find:fd"
 "ripgrep:rg"
 "du-dust"
 "eza"
 "bat"
 "procs"
 "bandwhich"
 "tealdeer:tldr"
 "git-delta:delta"
 "sd"
 "bottom:btm"
)

# Make sure that the cargo binary is in the path
export PATH="${PATH}:/home/${SUDO_USER:-${USER}}/.cargo/bin"
for util in "${cli_utilities[@]}"; do
  package="${util%%:*}"
  binary="${util##*:}"
  if ! which "${binary:?}" >/dev/null 2>/dev/null; then
    echo "Installing ${package:?}"
    if cargo install "${package:?}"; then 
      echo "Installed ${package:?}"
    else
      echo "Failed to install ${package:?}"
      exit 1
    fi
  fi
done
