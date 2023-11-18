#!/bin/bash


# Make sure that the cargo binary is in the path
export PATH="${PATH}:/home/${SUDO_USER:-${USER}}/.cargo/bin"

rust_toolchain="$(rustup show active-toolchain)"
if [[ -z "${rust_toolchain}" ]]; then
  rustup default stable
fi

# Set up a temporary directory and ensure it's cleaned up on script exit
RUNDIR=$(mktemp -d)
trap "rm -rf $RUNDIR" EXIT

# Main execution starts here
cd $RUNDIR || (echo "Failed to create temp directory" >&2; exit 1)

# Clone the eww repository
repo_url="https://github.com/elkowar/eww"
if ! git clone "${repo_url:?}"; then 
  echo "Failed to clone from ${repo_url:?}" >&2
  exit 1
fi
cd eww

# Detect the display server and build accordingly
if [[ $XDG_SESSION_TYPE == "x11" ]]; then
    echo "Building eww for X11..."
    cargo build --release --no-default-features --features x11
elif [[ $XDG_SESSION_TYPE == "wayland" ]]; then
    echo "Building eww for Wayland..."
    cargo build --release --no-default-features --features=wayland
else
    echo "Unknown session type. Defaulting to X11 build."
    cargo build --release --no-default-features --features x11
fi

if ! cp --no-preserve=ownership ./target/release/eww /usr/bin/eww; then 
  echo "Failed to copy the from ./target/release/eww to /usr/bin/eww" >&2
  exit 1
fi

echo "Build complete. Exiting..."
