#!/bin/zsh

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Define glyphs/icons
CHECKMARK="✔️"
WARN="⚠️ "
CROSS="❌"
INFO="ℹ️"
INSTALL="⬇️"
SKIP="⏩"
PKG="📦"

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

##### Languages and Frameworks #####

# Rust
install_rust() {
    echo -e "||===================== Checking and/or installing RUST =======================>"

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

    echo "<============================================||"
}

# Go
install_go() {
    echo -e "||===================== Checking and/or installing GOLANG =======================>"

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
       install_packages "pacman" "go"
    else
        pacman -S mingw-w64-x86_64-go
    fi

    echo "<============================================||"
}

# Flutter
install_flutter() {
    echo -e "||===================== Checking and/or installing FLUTTER =======================>"

    local download_folder="$HOME/Downloads"
    local pattern="^flutter_linux_"
    local flutter_files=$(fd -e tar.xz "$PATTERN")

    if ! command -v flutter &> /dev/null; then

        if [ -z "$flutter_files" ]; then
            echo -e "${WARN}${YELLOW}Warning: No Flutter .tar.xz files found in $download_folder.${NC}"
            echo "Remember to download the Flutter SDK from https://docs.flutter.dev/get-started/install/<OS>/<Target>"
            return
        fi

        echo -e "${CHECKMARK}${GREEN}Found the following Flutter .tar.xz files in $download_folder:${NC}"
        echo "$flutter_files" | while read -r file; do
            echo -e "📦 ${CYAN}$file${NC}"
        done

        # Extract the first matched file
        local first_file=$(echo "$flutter_files" | head -n 1)
        tar -xf "$first_file" -C "$HOME/code/tools/"

        echo -e "${CHECKMARK}${GREEN}Flutter installed successfully. Version: $(flutter --version)${NC}"

        echo -e "ℹ️ ${CYAN}Disabling Flutter integrated analytics to protect our privacy.${NC}"
        flutter --disable-analytics
        flutter config --no-analytics

        echo -e "🔧 ${CYAN}Running Flutter Doctor to check the installation health.${NC}"
        flutter doctor
    else
        echo -e "${CHECKMARK}${GREEN}Flutter is already installed. Version: $(flutter --version)${NC}"
    fi

    echo "<============================================||"
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
       install_packages pacman neovim
    else
        pacman -S mingw-w64-x86_64-neovim
    fi
}


##### Shell #####
setup_zsh() {
    echo "Setting up Zsh..."
    install_packages "pacman" "zsh"
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
        install_packages pacman uasm
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
	install_packages "cargo" "rm-improved" "xcp"
    fi

    install_packages "cargo" "starship" "bat" "lsd" "zoxide" "du-dust" "ripgrep" "fd-find" "sd" "procs" "bottom" "topgrade" "broot" "tokei"
    install_lazygit
}

gh_cli() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    	echo "Setting up GitHub CLI for Linux..."
	install_arch_pkgs "github-cli"
    else
        echo "Setting up GitHub CLI for Windows..."
    	git clone https://github.com/cli/cli.git gh-cli
    	cd gh-cli || exit
    	go run script\build.go
    fi
}

# Unified package installation function
install_packages() {
    local install_method="$1"
    shift  # Remove the first argument (install_method) to process the remaining package names

    local additional_args=()
    local packages=()

    # Separate packages and additional arguments
    for arg in "$@"; do
        if [[ "$install_method" = "snap" && "$arg" == --* ]]; then
            additional_args+=("$arg")
        else
            packages+=("$arg")
        fi
    done

    for package in "${packages[@]}"; do
        echo -e "||===================== ${package} =======================>"

        echo -e "${INSTALL}${YELLOW} Installing ${package} using ${install_method}...${NC}"

        case "$install_method" in
            cargo)
                if ! command -v $package &> /dev/null; then
                    cargo install "${additional_args[@]}" "$package"
                else
                    echo -e "${CHECKMARK}${GREEN} ${package} is already installed.${NC}"
                fi ;;
            pacman)
                if ! pacman -Qi "$package" &> /dev/null; then
                    sudo pacman -Sy "$package"
                else
                    echo -e "${CHECKMARK}${GREEN} ${package} is already installed.${NC}"
                fi ;;
            flatpak)
                if ! flatpak list | grep -q "^$package\s"; then
                    sudo flatpak install -y "${additional_args[@]}" "$package"
                else
                    echo -e "${CHECKMARK}${GREEN} ${package} is already installed.${NC}"
                fi ;;
            snap)
                if ! snap list | grep -q "^$package\s"; then
                    sudo snap install "$package" "${additional_args[@]}"
                else
                    echo -e "${CHECKMARK}${GREEN} ${package} is already installed.${NC}"
                fi ;;
            yay)
                if ! yay -Qi "$package" &> /dev/null; then
                    yay -Sy "$package"
                else
                    echo -e "${CHECKMARK}${GREEN} ${package} is already installed.${NC}"
                fi ;;
            *)
                echo -e "${ERROR}${RED} Unsupported installation method: ${install_method}${NC}"
                return 1 ;;
            esac

        # Check for the version of the installed package
        if [[ "$package" == "discord" || "$package" == "whatsapp-for-linux" || "$package" == "steam" ]]; then
            echo -e "${INFO} Skipping version check for ${package} as it launches the application."
        else
            # Check for the version of the installed package
            version=$("$package" --version 2>/dev/null || "$package" -v 2>/dev/null || "$package" version 2>/dev/null)
            if [ -n "$version" ]; then
                echo -e "${INFO} ${package} version: $version"
            else
                echo -e "${INFO} ${package} version: Unable to determine version"
            fi
        fi

        echo "<============================================||"
    done
}

# Takes care of enabling and/or initialize background processes and services
handle_daemon() {
    local service_name="$1"

    echo -e "||===================== Handling daemon: ${service_name} =======================>"

    if [ -z "$service_name" ]; then
        echo -e "${CROSS}${RED} No service name provided. Please provide a service name as an argument.${NC}"
        return 1
    fi

    # Check if the service is already active (running)
    if systemctl is-active --quiet "$service_name"; then
        echo -e "${CHECKMARK}${GREEN} $service_name is already running.${NC}"
    else
        # Check if the service is enabled
        if systemctl is-enabled --quiet "$service_name"; then
            echo -e "${WARN}${YELLOW} $service_name is enabled but not running. Starting it now...${NC}"
            sudo systemctl start "$service_name"
        else
            echo -e "${WARN}${YELLOW} $service_name is not enabled. Enabling and starting it now...${NC}"
            sudo systemctl enable --now "$service_name"
        fi

        # Confirm the service status
        if systemctl is-active --quiet "$service_name"; then
            echo -e "${CHECKMARK}${GREEN} $service_name is now running.${NC}"
        else
            echo -e "${CROSS}${RED} Failed to start $service_name.${NC}"
        fi
    fi


    echo "<============================================||"
}

try_create_dir() {
    local directory_path="$1"

    if [ ! -d "$directory_path" ]; then
        echo -e "Directory $directory_path does not exist. Creating..."
        mkdir "$directory_path"
        echo "Directory created."
    else
        echo "Directory $directory_path already exists."
    fi
}


################# GitHub personal and Zero Day Code projects #################
download_personal_projects() {
    echo -e "${INFO}${CYAN} Checking for 'git clone' my personal projects... ${NC}"

    local base_url=""
    try_create_dir "~/code/zero_day_code"

    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
       base_url="git@github.com:"
    else
       base_url="https://github.com/"
    fi

    local zdc_projects="${base_url}ZeroDayCode"
    local personal_projects="${base_url}TheRustifyer"

    ### The Zero Day Code ones
    git clone -v ${zdc_projects}/Canyon-SQL ~/code/zero_day_code/canyon-sql
    git clone -v ${zdc_projects}/Zork ~/code/zero_day_code/zork
    git clone -v ${zdc_projects}/Zero ~/code/zero_day_code/zero
    git clone -v ${zdc_projects}/Rumble-AI ~/code/zero_day_code/rumble-ai
    git clone -v ${zdc_projects}/Arcane ~/code/zero_day_code/arcane

    ### The personal ones
    git clone -v ${personal_projects}/PokemonGallaecia ~/code/pokemon-gallaecia
    git clone -v ${personal_projects}/Assembly-Atari-2600 ~/code/assembly-atari
    git clone -v ${personal_projects}/Rumble-LoL-Plugin ~/code/rumble-lol-plugin
}


################# Full setup for concrete Operating Systems #################
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
    install_packages cargo "alacritty" "zellij"

    # Install system packages
    install_packages pacman "yay" "xclip" "github-cli" "zip" "unzip" "xz" "pipewire" "pipewire-pulse" "pipewire-alsa" "pipewire-jack"

    # Development technologies
    install_packages pacman "base-devel" "gcc" "clang" "cmake" "ninja" "pkg-config" "strace" "fmedia"

    # More toolchains (via AUR)
    install_packages yay "llvm16"

    # Snap
    install_packages pacman "snapd"
    if [ -L "/snap" ]; then
        echo -e "${INFO}${CYAN} Snap symbolic link already created${NC}"
    else
        sudo ln -s /var/lib/snapd/snap /snap # Enabling legacy snaps
    fi

    # Enabling and/or starting the needed services on demand
    handle_daemon "snapd.socket"

    # Install apps and programs for confort/entertainment/communication
    install_packages pacman "discord" "ksnip"
    install_packages snap "steam" "whatsapp-for-linux"

    # Game Dev utils
    install_packages flatpak "flathub io.github.achetagames.epic_asset_manager"

    # Install frameworks
    install_flutter

    # Install the other code editors
    install_packages snap "code" "rustrover" "clion" "--classic"

    # Download my most used repositories
    download_personal_projects
    echo -e "${CHECKMARK}${GREEN} Setup finished!${NC}"
}


#################### MAIN PROCESS ####################

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

        -dwp|--download-projects) download_personal_projects ;;
        -sm|--setup-manjaro) setup_manjaro ;;

        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

