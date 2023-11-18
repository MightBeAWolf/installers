packages=(
  paru
)

if which cargo >/dev/null 2>/dev/null; then 
  for package in "${packages[@]}"; do
    echo "Installing $package"
    if cargo install "${package}"; then 
      echo "Installed ${package}"
    else
      echo "Failed to install ${package}"
    fi
  done
else
  echo "Cargo is not installed."
  echo "Please install Cargo before running this script"
  exit 1  
fi
