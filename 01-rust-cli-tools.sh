#!/bin/bash
# Make sure that the cargo binary is in the path
export PATH="${PATH}:/home/${SUDO_USER:-${USER}}/.cargo/bin"
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
 "trippy:trip"
 "xsv"
 "funzzy:fzz"
 "rargs"
 "skim:sk"
 "tealdeer:tldr"
 "git-delta:delta"
 "sd"
 "mdcat"
 "bottom:btm"
)

failed_to_install=()
for util in "${cli_utilities[@]}"; do
  package="${util%%:*}"
  binary="${util##*:}"
  if ! which "${binary:?}" >/dev/null 2>/dev/null; then
    echo "Installing ${package:?}"
    if cargo install "${package:?}"; then 
      echo "Installed ${package:?}"
    else
      echo "Failed to install ${package:?}"
      failed_to_install+=(${package:?})
    fi
  fi
done

if [[ "${#failed_to_install[@]}" -gt 0 ]]; then
  echo "Failed to install:" >&2
  for package in "${failed_to_install[@]}"; do
    echo -e "\t${package:?}" >&2
  done
  exit 1
fi
