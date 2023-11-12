#!/bin/bash

# Check if yay is already installed
if command -v yay &> /dev/null; then
  echo "yay is already installed. No action needed."
  exit 0
fi

# Check for dependencies
dependencies=("git" "makepkg" "pacman")
for dep in "${dependencies[@]}"; do
  if ! command -v "$dep" &> /dev/null; then
    echo "Error: Required dependency '$dep' is not installed." >&2
    exit 1
  fi
done

# Check if required packages are already installed
if ! pacman -Qq base-devel &> /dev/null; then
  # Install necessary packages with pacman
  if ! pacman -S --needed git base-devel; then
    echo "Error: Failed to install base-devel package with pacman." >&2
    exit 1
  fi
fi

# Create a temporary directory and ensure it's deleted on script exit
sudo -u "${SUDO_USER:-$USER}" temp_dir=$(mktemp -d)
trap 'rm -rf -- "$temp_dir"' EXIT

# Clone the yay repository
if ! sudo -u "${SUDO_USER:-$USER}" git clone https://aur.archlinux.org/yay.git "$temp_dir/yay"; then
  echo "Error: Failed to clone yay repository." >&2
  exit 1
fi

cd "$temp_dir/yay" || (echo "Error: Failed to cd into yay repo" >&2; exit 1)

# Make and install yay package
if ! sudo -u "${SUDO_USER:-$USER}" makepkg -si; then
  echo "Error: Failed to make and install yay package." >&2
  exit 1
fi

echo "yay installed successfully."
