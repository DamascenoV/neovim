#!/bin/bash

# Exit on error
set -e

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo "Installing global npm language servers..."

npm install -g \
  vscode-langservers-extracted \
  @olrtg/emmet-language-server \
  intelephense \
  @vtsls/language-server \
  @vue/language-server \
  @github/copilot-language-server

echo "Installing lua-language-server..."

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command_exists brew; then
        brew install lua-language-server
    else
        echo "Homebrew not found. Please install Homebrew to continue."
        exit 1
    fi
else
    # Linux
    echo "Installing lua-language-server on Linux..."
    LLS_REPO="https://github.com/LuaLS/lua-language-server"
    LLS_DIR="$HOME/lua-language-server"

    if [ ! -d "$LLS_DIR" ]; then
        git clone "$LLS_REPO" "$LLS_DIR"
    fi

    cd "$LLS_DIR"
    git submodule update --init --recursive
    cd 3rd/luamake
    ./compile/install.sh
    cd ../..
    ./3rd/luamake/luamake rebuild

    echo "Lua language server built at $LLS_DIR/bin"
    echo "Consider adding it to your PATH."
fi

echo "Installing Go language servers..."

if ! command_exists go; then
    echo "Go is not installed. Please install Go and try again."
    exit 1
fi

go install github.com/laravel-ls/laravel-ls/cmd/laravel-ls@latest
go install golang.org/x/tools/gopls@latest

echo "All installations completed."

