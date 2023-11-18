packages=(
  paru
)

# Make sure that the cargo binary is in the path
export PATH="${PATH}:/home/${SUDO_USER:-${USER}}/.cargo/bin"

# Make sure the user has a tool chain
rust_toolchain="$(rustup show active-toolchain)"
if [[ -z "${rust_toolchain}" ]]; then
  rustup default stable
fi

if which cargo >/dev/null 2>/dev/null; then 
  for package in "${packages[@]}"; do
    echo "Installing $package"
    if cargo install "${package}"; then 
      echo "Installed ${package}"
    else
      echo "Failed to install ${package}"
      exit 1
    fi
  done
else
  echo "Cargo is not installed."
  echo "Please install Cargo before running this script"
  exit 1  
fi
