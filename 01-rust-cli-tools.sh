#!/bin/bash

cli_utilities=(
 "fd-find"
 "ripgrep"
 "du-dust"
 "helix-term"
 "eza"
 "bat"
 "procs"
 "bandwhich"
 "tealdeer"
 "git-delta"
 "sd"
 "bottom"
)

# Make sure that the cargo binary is in the path
export PATH="${PATH}:/home/${SUDO_USER:-${USER}}/.cargo/bin"
if which cargo >/dev/null 2>/dev/null; then 
  for util in "${cli_utilities[@]}"; do
    echo "Installing $util"
    if cargo install "${util}"; then 
      echo "Installed ${util}"
    else
      echo "Failed to install ${util}"
      exit 1
    fi
  done
else
  echo "Cargo is not installed."
  echo "Please install Cargo before running this script"
  exit 1  
fi
