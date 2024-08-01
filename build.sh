#!/bin/zsh

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Define glyphs/icons
CHECKMARK="✔️"
CROSS="❌"
INFO="ℹ️"
INSTALL="⬇️"
SKIP="⏩"

# Function to load environment
load_env() {
    if [ -f ~/.zshrc ]; then
        echo -e "${INFO}${CYAN} Sourcing ~/.zshrc${NC}"
        source ~/.zshrc
    fi
}

# Define the 'config' alias within the script
config() {
    git --git-dir=$HOME/.cfg/ --work-tree=$HOME "$@"
}

##### Languages #####

# Rust
install_rust() {
    if command -v rustc &> /dev/null; then
        echo -e "${CHECKMARK}${GREEN} Rust is already installed. Skipping Rust installation.${NC}"
        echo -e "${INFO}${CYAN} Installed Rust version: $(rustc --version)${NC}"
    else
        echo -e "${INSTALL}${YELLOW} Rust not found. Installing Rust...${NC}"
        curl https://sh.rustup.rs -sSf | sh
        source $HOME/.cargo/env  # Load Rust environment

        # Check again after installation
        if command -v rustc &> /dev/null; then
            echo -e "${CHECKMARK}${GREEN} Rust installed successfully. Version: $(rustc --version)${NC}"
        else
            echo -e "${CROSS}${RED} Error: Rust installation failed or Rust not found in PATH.${NC}"
        fi
    fi
}

# Go
install_go() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
       install_arch_pkgs "go" 
    else
        pacman -S mingw-w64-x86_64-go
    fi
}


##### Editor #####
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
       install_arch_pkgs "neovim" 
    else
        pacman -S mingw-w64-x86_64-neovim
    fi
}


##### Shell #####
setup_zsh() {
    echo "Setting up Zsh..."
    install_arch_pkgs "zsh" 
    git clone https://github.com/zsh-users/zsh-completions.git ~/.zsh/zsh-completions
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
    exec zsh
}

##### Code #####

# The LLVM suite, for having Clang and all it's associated dev tools build from the latest changes
build_llvm_suite() {
    echo "Updating the LLVM project suite..."
    config submodule update --init --remote code/third-party/llvm-project
    echo "Building LLVM suite..."
    cd ~/code/third-party/llvm-project || exit
    mkdir -p build
    cmake -G Ninja -S runtimes -B build -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind"
    ninja -C build
}

# Assemblers and assembly tools

# DASM (Mostly used to build games for the Atari 2600)
build_dasm() {
    config submodule update --init --remove code/tools/dasm-assembler
    cd code/tools/dasm-assembler
    make
}

# The universal assembler (mostly used for me to assemble MASM Microsoft into universal ELF)
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
    if ! command -v lazygit &> /dev/null; then
        echo -e "${INSTALL}${YELLOW} Installing Lazygit...${NC}"
        go install github.com/jesseduffield/lazygit@latest
    else
        echo -e "${CYAN}${INFO} Lazygit is already installed.${NC}"
    fi

    lazygit --version
}

# Install all the CMD utilities directly with Cargo
terminal_tools() {
    # Here lives the ones available only on Linux
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	install_cargo_pkgs "rm-improved" "xcp"
    fi

    install_cargo_pkgs "starship" "bat" "lsd" "zoxide" "du-dust" "ripgrep" "fd-find" "sd" "procs" "bottom" "topgrade" "broot" "tokei"
    install_lazygit
}

gh_cli() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Setting up GitHub CLI for Windows..."
    	git clone https://github.com/cli/cli.git gh-cli
    	cd gh-cli || exit
    	go run script\build.go
    else
    	echo "Setting up GitHub CLI for Linux..."
	sudo pacman -Sy github-cli
    fi
}


# Utility function to install all the packages via Cargo passed as arguments, handling the case when they
# are already present on the system
install_cargo_pkgs() {
    for package in "$@"; do
        if ! command -v $package &> /dev/null; then
            echo -e "${INSTALL}${YELLOW} Installing ${package}...${NC}"
            cargo install $package
        else
            echo -e "${CYAN}${INFO} ${package} is already installed.${NC}"
        fi

        version=$($package --version 2>/dev/null || $package -v 2>/dev/null)
        if [ -n "$version" ]; then
             echo -e "ℹ️  ${package} version: $version"
        else
             echo -e "ℹ️  ${package} version: Unable to determine version"
        fi
    done
}

############# Manjaro Distro Setup #############

# Utility function to install all the packages via Pacman passed as arguments, handling the case when they
# are already present on the system
install_arch_pkgs() {
    for package in "$@"; do
        if ! pacman -Qi $package &> /dev/null; then
            echo -e "${INSTALL}${YELLOW} Installing ${package}...${NC}"
            sudo pacman -Sy $package
        else
            echo -e "${CYAN}${INFO} ${package} is already installed.${NC}"
        fi

        version=$($package --version 2>/dev/null || $package -v 2>/dev/null)
        if [ -n "$version" ]; then
             echo -e "ℹ️  ${package} version: $version"
        else
             echo -e "ℹ️  ${package} version: Unable to determine version"
        fi
    done
}

# Function to install system packages
install_system_packages() {

    install_arch_pkgs "xclip" "base-devel" "gcc" "github-cli"

    # if ! command -v
}

# This configures my typical apps and packages, among other configurations in a Manjaro distro
setup_manjaro() {
    echo -e "${INFO}${CYAN} Running a Manjaro setup in shell: $SHELL${NC}"

    # Load environment
    load_env

    # Install Rust
    install_rust

    # Install Golang
    install_go

    # Install Neovim as the primary text editor
    install_editor

    # Install the terminal tools
    terminal_tools
    
    # Install the Alacritty && Zellij terminal multiplexing combo
    install_alacritty
    install_zellij

    # Install system packages
    install_system_packages

    # Install frameworks
    install_flutter

    echo -e "${CHECKMARK}${GREEN} Setup finished!${NC}"
}


# Load my real OS environment
load_env

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

        -bllvm|--build-llvm-suite) build_llvm_suite ;;
        -uasm|--install-uasm) install_uasm ;;
        -dasm|--build-dasm) build_dasm ;;
        
	-sm|--setup-manjaro) setup_manjaro ;;

        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

