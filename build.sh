#!/bin/bash

# Define the 'config' alias within the script
config() {
    git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"
}

# Install all the CMD utilities directly with Cargo
terminal_tools() {
    # Here lives the ones available only on Linux
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Terminal multiplexer. It doens't work yet on Windows:
        # but looks promising: https://github.com/zellij-org/zellij/pull/2926
        echo "Installing Zellij..."
        cargo install zellij --locked
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
    echo "Installing a better ls via eza..."
    cargo install eza
    
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

setup_zsh() {
    echo "Setting up Zsh..."
    pacman -S zsh
    ## config submodule update --init --remote code/third_party/oh-my-zsh
    git clone https://github.com/zsh-users/zsh-completions.git
    # git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    # git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    exec zsh
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


function update_wezterm() {
    config submodule update --init --remote --recursive code/third-party/wezterm  # Adjust 'code/third-party/wezterm' if needed
    cd code/third_party/wezterm                                        # Navigate to the submodule directory
    ./get-deps                                               # Fetch dependencies
    cargo build --release                                    # Build wezterm in release mode
    cd ~
}


function update_zellij() {
    config submodule update --init --remote --recursive code/third-party/zellij
    cd code/third_party/zellij
    cargo build --release
    cd ~
}

# Check the arguments to determine which component to build
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -z|--zsh) setup_zsh ;;
        -g|--gh-cli-windows) gh_cli_windows ;;
        -l|--gh-cli-linux) gh_cli_linux ;;
        -ullvm|--update-llvm-suite) update_llvm_suite ;;
        -bllvm|--build-llvm-suite) build_llvm_suite ;;
        -uw|--update_wezterm) update_wezterm ;;
        -uz|--update_zellij) update_zellij ;;
        -tt|--terminal-tools) terminal_tools ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

