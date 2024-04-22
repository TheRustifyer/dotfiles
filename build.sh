#!/bin/bash

# Define the 'config' alias within the script
config() {
    git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"
}

##### Languages #####
# Rust
install_rust() {
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --no-modify-path
}

# Go
install_go() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        pacman -S go
    else
        pacman -S mingw-w64-x86_64-go
    fi
}


##### Languages #####
# Build Neovim
build_neovim() {
    config submodule update --init --remote code/tools/neovim
    cd code/tools/neovim
    mingw32-make deps
    mingw32-make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX="$HOME"
    mingw32-make install
}

# Install Neovim
install_editor() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        pacman -S neovim
    else
        pacman -S mingw-w64-x86_64-neovim
    fi
}


##### Editor #####
setup_zsh() {
    echo "Setting up Zsh..."
    pacman -S zsh
    git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
    exec zsh
}

##### Code #####

# The LLVM suite, for having Clang and all it's associated dev tools build from the latest changes
update_llvm_suite() {
    echo "Updating the LLVM project suite..."
    config submodule update --init --remote code/third_party/llvm-project
}

build_llvm_suite() {
    echo "Building LLVM suite..."
    cd ~/code/third_party/llvm-project || exit
    mkdir -p build
    cmake -G Ninja -S runtimes -B build -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS='clang;lld;clang-tools-extra;lldb' -DLLVM_USE_LINKER=lld -DLLVM_PARALLEL_COMPILE_JOBS=8 -DLLVM_PARALLEL_LINK_JOBS=8 -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"
    ninja -C build
}

install_uasm() {
    echo "Building the UASM project..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo pacman -S uasm
    else
        pacman -S mingw-w64-x86_64-uasm
    fi
}

##### Terminal emulators and multiplexers  #####

# Alacritty
function install_alacritty() {
    cargo install alacritty
}

function build_alacritty() {
    config submodule update --init --remote --recursive code/tools/wezterm
    cd code/tools/alacritty
    cargo build --release
    cd ~
}

# Zellij
function install_zellij() {
    cargo install zellij --locked
}

function build_zellij() {
    config submodule update --init --remote --recursive code/tools/zellij
    cd code/tools/zellij
    cargo build --release
    cd ~
}

# Currently only builds yet from the pr referenced below
# Terminal multiplexer. It doens't work yet on Windows:
# but looks promising: https://github.com/zellij-org/zellij/pull/2926
function build_zellij_win() {
    config submodule update --init --remote --recursive code/third-party/zellij
    cd code/third-party/zellij
    cargo build --release
    cd ~
}

# Wezterm
function build_wezterm() {
    config submodule update --init --remote --recursive code/tools/wezterm
    cd code/tools/wezterm
    ./get-deps
    cargo build --release
    cd ~
}

##### CLI tools and utilities #####

# Lazygit
install_lazygit() {
    go install github.com/jesseduffield/lazygit@latest
}

# Install all the CMD utilities directly with Cargo
terminal_tools() {
    # Here lives the ones available only on Linux
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Improved `rm` command
        echo "Installing a better rm command. rm-improved..."
        cargo install rm-improved
        # xcp is a partial clone of the `cp` command
        echo "Installing a better cp command..."
        cargo install xcp
    fi

    # Terminal prompt
    echo "Installing Starship..."
    cargo install starship --locked
    # A better `cat`
    echo "Installing bat, a better cat ;) ..."
    cargo install --locked bat
    # Replacements for the `ls` command
    echo "Installing a better ls via LSD..."
    cargo install lsd
    # zoxide is a smarter `cd` replacement
    echo "Installing zoxide, a smarted cd command..."
    cargo install zoxide --locked
    # A much better `du` command
    echo "Installing a better du command..."
    cargo install du-dust
    # ripgrep, the real search-tool (`grep` replacement)
    echo "Installing a real improved, modern looking and really powerful text search tool..."
    cargo install ripgrep
    # Simpler alternative to find (more intuitive, better defaults)
    echo "Finally having a real good cmd utility to search for things in your hard drives..."
    cargo install fd-find
    # Modern and (much) more user friendly `sed` and `awk`
    echo "Installing a better sed and/or awk utility..."
    cargo install sd
    # `ps` replacement
    echo "Installing a ps replacement..."
    cargo install procs
    # `top` replacement, completly cross-platform
    echo "Installing a top/htop replacement, known as bottom..."
    cargo install bottom --locked
    # Have your system up-to-date, completly cross-platform
    echo "Installing a system-updater..."
    cargo install topgrade --locked
    # a `tree` alternative
    echo "Installing a tree like utility..."
    cargo install broot --locked
    # nice utility to count lines and stats of code
    echo "Installing a counter of lines and stats for source code..."
    cargo install tokei
}

gh_cli_windows() {
    echo "Setting up GitHub CLI for Windows..."
    config clone https://github.com/cli/cli.git gh-cli
    cd gh-cli || exit
    go run script\build.go
}

gh_cli_linux() {
    echo "Setting up GitHub CLI for Linux..."
    config clone https://github.com/cli/cli.git gh-cli
    cd gh-cli || exit
    bin/gh version
}

gh_cli() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        gh_cli_linux
    else
        gh_cli_windows
    fi
}


# Check the arguments to determine which component to build
while [[ "$#" -gt 0 ]]; do
    case $1 in
        # Languages
        -rust|--install_rust) install_rust ;;
        -go|--install_go) install_go ;;
        -java|--install_java) install_java ;;
        -dart|--install_dart) install_dart ;;
        -py|--install_python) install_python ;;

        # TODO Game engines (GODOT pls)

        # Frameworks // TODO sure is worth the effort?
        -flutter|--install_flutter) install_flutter ;;

        # Shells
        -zsh|--setup_zsh) setup_zsh ;;

        # Editor
        -bnv|--build-neovim) build_neovim ;;
        -inv|--install-neovim) install_editor ;;

        # Terminal emulators
        -ia|--install_alacritty) install_alacritty ;;
        -ba|--build_alacritty) build_alacritty ;;

        -iz|--iz_zellij) install_zellij ;;
        -bz|--build_zellij) build_zellij ;;
        -bzw|--build_zellij_win) build_zellij_win ;;

        -bw|--build_wezterm) build_wezterm ;;

        -tt|--terminal-tools) terminal_tools ;;
        -lg|--install-lazygit) install_lazygit ;;
        -g|--gh-cli) gh_cli ;;

        -ullvm|--update-llvm-suite) update_llvm_suite ;;
        -bllvm|--build-llvm-suite) build_llvm_suite ;;
        -uasm|--install-uasm) install_uasm ;;

        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

