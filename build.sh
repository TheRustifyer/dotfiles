#!/bin/bash

# Define the 'config' alias within the script
config() {
    git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"
}

setup_zsh() {
    echo "Setting up Zsh..."
    config submodule update --init --remote code/third_party/oh-my-zsh
    git clone https://github.com/zsh-users/zsh-completions.git
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
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

function general_tools() {
    cargo install --locked bat # A better `cat`
}


# Check the arguments to determine which component to build
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--general-tools) general_tools ;;
        -z|--zsh) setup_zsh ;;
        -g|--gh-cli-windows) gh_cli_windows ;;
        -l|--gh-cli-linux) gh_cli_linux ;;
        -ullvm|--update-llvm-suite) update_llvm_suite ;;
        -bllvm|--build-llvm-suite) build_llvm_suite ;;
        -uw|--update_wezterm) update_wezterm ;;
        -uz|--update_zellij) update_zellij ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

