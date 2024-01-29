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
cd "${TMP_DIR:?}"

# If the user's .cargo bin directory exists,
# but doesn't exist in the path, update the path.
if [[ -d "${HOME}/.cargo/bin" ]] \
&& ! grep -qP "\b:?${HOME}/.cargo/bin:?\b" <<< "${PATH}"; then 
    export PATH="${HOME}/.cargo/bin:${PATH}"
fi

# Check for dependencies
dependencies=("git" "cargo" "g++")
for dep in "${dependencies[@]}"; do 
    if [ -n "$dep" ] && ! command -v $dep &> /dev/null; then
        echo "Error: Missing dependency $dep"
        exit 1
    fi
done

# Clone the Helix repository if it does not exist
git clone https://github.com/helix-editor/helix "./helix"
cd "./helix"

# Checkout the latest stable release
LATEST_RELEASE="$( git ls-remote -q --tags \
    | awk '{print $2}' \
    | xargs -I{} git log -1 --format='%at %H' {} \
    | sort -h \
    | tail -n 1 \
    | awk '{print $2}')"
git checkout "${LATEST_RELEASE:?}"

# Temporary fix for https://github.com/helix-editor/helix/pull/8932
sed -i '1s/^/use-grammars = { except = ["gemini"] }\n/' languages.toml

# Build and install Helix from source
if ! cargo install --path "./helix-term" --locked; then 
    echo "Failed to install helix!"
    exit 1
fi

# Move the runtimes into the config
mkdir -p "$HOME/.config/helix"
if [[ -e "$HOME/.config/helix/runtime" ]]; then 
    rm -rf "$HOME/.config/helix/runtime"
fi
mv "./runtime" "$HOME/.config/helix"

# Fetch and compile tree-sitter grammars
"$HOME/.cargo/bin/hx" --grammar fetch
"$HOME/.cargo/bin/hx" --grammar build

echo "Helix installation complete"

