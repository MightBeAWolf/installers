#!/bin/bash

# Temporary directory for downloading and extracting fonts
TMP_DIR=$(mktemp -d -t starship-install-XXXXXXXXXX)

# Font installation directory
FONT_DIR="$HOME/.local/share/fonts"

# Font zip file name
FONT_ZIP="FiraCode.zip"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip"

# Cleanup function to remove temporary directory
cleanup() {
    echo "Cleaning up temporary files..."
    rm -rf "$TMP_DIR"
}

# Trap for cleanup on exit or interruption
trap cleanup EXIT ERR INT TERM

# Check for existing FiraCode font
font_exists=$(find "$FONT_DIR" -type f -name 'Fira Code Regular Nerd Font Complete.ttf' | head -n 1)

# Download and install fonts if they aren't already installed
if [ -z "$font_exists" ]; then
    # Check for curl and unzip
    if ! command -v curl &> /dev/null; then
        echo "Error: curl is not installed." >&2
        exit 1
    fi

    if ! command -v unzip &> /dev/null; then
        echo "Error: unzip is not installed." >&2
        exit 1
    fi

    # Download FiraCode Nerd Font
    echo "Downloading FiraCode Nerd Font..."
    if curl -L -o "$TMP_DIR/$FONT_ZIP" "$FONT_URL"; then
        # Unzip and install the font
        echo "Installing FiraCode Nerd Font..."
        mkdir -p "$FONT_DIR"
        unzip -q "$TMP_DIR/$FONT_ZIP" -d "$FONT_DIR"
        rm -f "$TMP_DIR/$FONT_ZIP" # Remove the zip file after extracting

        # Rebuild font cache
        if command -v fc-cache &> /dev/null; then
            fc-cache -fv
        fi
    else
        echo "Error: Failed to download FiraCode.zip" >&2
        exit 1
    fi
else
    echo "FiraCode Nerd Font is already installed."
fi

# Install Starship
echo "Installing Starship terminal prompt..."
if sh -c "$(curl -fsSL https://starship.rs/install.sh)"; then
    echo "Starship installed successfully!"
    echo "Add the following line to your shell configuration file (e.g., ~/.bashrc, ~/.zshrc):"
    echo 'eval "$(starship init bash)"'
else
    echo "Error: Starship installation failed." >&2
    exit 1
fi

echo "Installation complete."

