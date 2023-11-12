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

if which cargo >/dev/null 2>/dev/null; then 
  for util in "${cli_utilities[@]}"; do
    echo "Installing $util"
    if cargo install "${util}"; then 
      echo "Installed ${util}"
    else
      echo "Failed to install ${util}"
    fi
  done
else
  echo "Cargo is not installed."
  echo "Please install Cargo before running this script"
  exit 1  
fi
