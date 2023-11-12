#!/bin/bash

# Function to clean up temporary directory
cleanup() {
    echo "Cleaning up temporary files..."
    rm -rf "$TMP_DIR"
}

# Trap to clean up in case of error or script exit
trap cleanup EXIT ERR INT TERM

# Create a temporary directory
TMP_DIR=$(mktemp -d -t helix-install-XXXXXXXXXX)

# Check for dependencies
dependencies=("git" "cargo" "g++")
for dep in "${dependencies[@]}"; do 
    if [ -n "$dep" ] && ! command -v $dep &> /dev/null; then
        echo "Error: Missing dependency $dep"
        exit 1
    fi
done

# Clone the Helix repository if it does not exist
git clone https://github.com/helix-editor/helix "$TMP_DIR/helix"

# Build and install Helix from source
if ! cargo install --path "$TMP_DIR/helix/helix-term" --locked; then 
    echo "Failed to install helix!"
    exit 1
fi

# Move the runtimes into the config
mkdir -p "$HOME/.config/helix"
if [[ -e "$HOME/.config/helix/runtime" ]]; then 
    rm -rf "$HOME/.config/helix/runtime"
fi
mv "$TMP_DIR/helix/runtime" "$HOME/.config/helix"

# Fetch and compile tree-sitter grammars
"$HOME/.cargo/bin/hx" --grammar fetch
"$HOME/.cargo/bin/hx" --grammar build

echo "Helix installation complete"

