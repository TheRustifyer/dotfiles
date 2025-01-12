# HOME as $HOME, pls ;)
export HOME="$HOME"

export HIST_STAMPS="dd.mm.yyyy"
# set the location and filename of the history file
export HISTFILE="$HOME/.zsh_history"

# set the maximum number of lines to be saved in the history file
export HISTSIZE="100000"
export SAVEHIST="$HISTSIZE"

# User configuration
export TERM=xterm-256color
# You may need to manually set your language environment
export LANG=en_US.UTF-8
# Preferred editor
export EDITOR='nvim'
# ZSH root
fpath=(~/.zsh $fpath)
# Disable the prompt asking for load .env files on your cwd
export ZSH_DOTENV_PROMPT=false

# enable comments "#" expressions in the prompt shell
setopt INTERACTIVE_COMMENTS

# append new history entries to the history file
setopt APPEND_HISTORY

# save each command to the history file as soon as it is executed
setopt INC_APPEND_HISTORY

# ignore recording duplicate consecutive commands in the history
setopt HIST_IGNORE_DUPS

# ignore commands that start with a space in the history
setopt HIST_IGNORE_SPACE

# ASDF
if [ -d "$HOME/.asdf" ]; then
  echo -e "Loading 'asdf'"
  . "$HOME/.asdf/asdf.sh"
  fpath=("${HOME}/.asdf/completions" $fpath)
fi

# Job CFG specifics
if [ -f "$HOME/.job_cfg" ]; then
    echo -e "Loading JOB configuration"
    source "$HOME/.job_cfg"
fi

# The 'git' autocompletion script
zstyle ':completion:*:*:git:*' script ~/.git-completion.bash
autoload -Uz compinit && compinit

__git_files () {
    _wanted files expl ‘local files’ _files
}


# zsh built-in plugins
plugins=(git asdf)

# Keybindings
bindkey -v # Enabling the VI mode on ZSH by default, instead of the 'Emacs' one
bindkey '^R' history-incremental-search-backward # Having the Ctrl+R keybinding for having a bash-like reverse search

# navigate words using Ctrl + arrow keys
# >>> CRTL + right arrow | CRTL + left arrow
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# search history using Up and Down keys
# >>> up arrow | down arrow
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# jump to the start and end of the command line
# >>> CTRL + A | CTRL + E
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
# >>> Home | End
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# Set personal aliases
# TODO: move them to their own mod
alias vi=nvim
alias lg='lazygit'
alias lgd='lazygit --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias ..='cd ..'
alias bashcls='echo "" > ~/.bash_history'
alias cls='clear'

alias ls='lsd -F'
alias lsl='lsd -F -l'
alias lsa='lsd -F -la'
alias lss='lsd -F -la -S'
alias lst='lsd -F -la -t'
alias lsg='lsd -F -la -G'

alias rmdir='rm -rf'

alias ez='exec zsh'

alias zshconf="nvim ~/.zshrc"
alias zellijconf='nvim ~/.config/zellij/config.kdl'
alias wezconf='cd ~/.config/wezterm'

## Projects
alias zork='cd $HOME/code/zdc/zork'
alias zero='cd $HOME/code/zdc/zero'
alias zmk='cd $HOME/code/own/zmk-config'

## Custom tools

# Using `bat` as a better `cat`
alias cat='bat'

# Using `bat` as a better `cat`
alias du='dust'

# Using `fd-find` as a MUCH better `find`
alias find='fd'

# Using `ripgrep` as a better `grep`
# alias grep='rg' ## I am not quite ready yet :)

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias nvimconf='cd ~/.config/nvim && nvim'
    alias nvimdir='cd ~/.config/nvim'
    alias rmnvim="fd '.*nvim.*' ~/.cache ~/.local --type d --exec rm -rf {}"
    alias alaconf='nvim ~/.config/alacritty/alacritty.toml'

    # Weston, the compositor of gui envs
    # # Weston creating a full HD windows within a X11 session
    alias w11="weston --backend=x11-backend.so --width=$(xdpyinfo | awk '/dimensions:/ {print $2}' | cut -d'x' -f1) --height=$(xdpyinfo | awk '/dimensions:/ {print $2}' | cut -d'x' -f2)"
    alias wd="w11 > /dev/null 2>&1 &"

    # Run 'Waydroid' with 'Wayland'. That's the reason that we need Weston, due to X11 being the default in all my desktops.
    # 'Waydroid' only runs on 'Wayland', and that's where comes 'Weston'
    alias wss='WAYLAND_DISPLAY=waydroid-1 waydroid session start'
    alias wl='waydroid show-full-ui'

    # Clean Waydroid data (without removing it the installation from the system)
    alias clwaydroid='sudo rm -rf /var/lib/waydroid /home/.waydroid ~/waydroid ~/.share/waydroid ~/.local/share/waydroid ~/.local/share/applications/*aydroid*' # last one can produce 'no matches'
    alias multi_win_waydroid='waydroid prop set persist.waydroid.multi_windows true' # last one can produce 'no matches'
 
    # GUI tools from shell
    alias pd="postman > /dev/null 2>&1 &"
    alias db='dbeaver-ce > /dev/null 2>&1 &'
    alias wa='whatsapp-linux-app > /dev/null 2>&1 &'
else
    alias wincode='cd ~/code'
    alias appdata='cd ~/AppData'

    alias nvimconf='cd ~/AppData/Local/nvim && nvim'
    alias nvimdir='cd ~/AppData/Local/nvim'

    alias rmnvim='rm -rf ~/AppData/Local/nvim && rm -rf ~/AppData/Local/nvim-data'

    alias alaconf='nvim ~/AppData/Roaming/alacritty/alacritty.toml'
fi

# Overpowering the access to edit my projects, "thanks" to the `Zellij` layouts
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias wzork='alacritty -e zellij --layout zork &'
    alias wzero='alacritty -e zellij --layout zero &'
else
    alias wzork='alacritty -e zellij --layout zork_win &'
    alias wzero='alacritty -e zellij --layout zero_win &'
fi

# Alias for some commands to be named as the Pacman package
alias github-cli='gh'
alias neovim='nvim'
alias du-dust='du'
alias ripgrep='rg'
alias fd-find='fd'
alias bottom='btm'
alias rm-improved='rip'

# Git aliases
alias gs='git status -sb'
alias gco='git checkout'
alias gcm='git checkout main'
alias gaa='git add --all'
alias gco='git commit -m $2'
alias gp='git push'
alias gpo='git push origin'
alias gpll='git pull'
alias gcl='git clone'
alias gst='git stash'
alias gsp='git stash pop'
alias ga='git add'
alias gb='git branch'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gm='git merge'
alias gmnff='git merge --no-ff'

# For work with my bare git repo for the dotfiles
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Cargo bin PATH
export PATH="$HOME/.cargo/bin:$PATH"
# # Golang bin PATH
# export PATH="$HOME/go/bin:$PATH"
# export GOROOT="$HOME/go/bin"

# Linux specifics
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # This adds the packages downloaded via SNAP accessible via command line
    export PATH="/var/lib/snapd/snap/bin:$PATH"
    # snap
    export PATH="/snap/bin:$PATH"
    # Raw LLVM suite (20)
    export PATH="/usr/lib/llvm-20/bin:$PATH"
fi
# Windows specifics
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    # Having GitHub CLI avaliable on path on Windows
    export PATH="$HOME/gh-cli/bin:$PATH"
    # Making the git-for-windows binaries available to the msys2 envs
    export PATH="$HOME/AppData/Local/Programs/Git/cmd:$PATH"
    # The MSYS2 binary paths for the desired environments
    export PATH="/c/msys64/mingw64/bin:/c/msys64/clang64/bin:/c/msys64/usr/bin:/c/msys64/usr/local/bin:/c/msys64/opt/bin:$PATH"

    #export GOROOT="/c/msys64/mingw64"
fi

# The LLVM project, full suite. Defined after the msys2 to appear before on $PATH if the manual build is present on the system
LLVM_PROJECT_DIR="$HOME/code/third-party/llvm-project"
BUILD_DIR="$LLVM_PROJECT_DIR/build"
if [ -d "$BUILD_DIR" ]; then
  # Add build directory to PATH and LD_LIBRARY_PATH
  export PATH="$BUILD_DIR/bin:$PATH"
  export LD_LIBRARY_PATH="$BUILD_DIR/lib:$LD_LIBRARY_PATH"
fi

# DASM assembler for the Atari 2600
export PATH="$HOME/code/tools/dasm-assembler/bin:$PATH"

# Flutter as installed on my regular code/tools PATH as a third-party dependency
export PATH="$HOME/code/tools/flutter/bin:$PATH"

# Job related cfg
HOSTNAME=$(hostname)

if [[ "$HOSTNAME" == PC_ECO* ]]; then
    if [ -f ~/.job_cfg ]; then
        source ~/.job_cfg
    fi
fi

# Starship!
# function set_win_title() {
#     echo -ne "\033]0; $(basename "$PWD") \007"
# }
# starship_precmd_user_func="set_win_title"

function blastoff() {
    echo "🚀"
}
starship_precmd_user_func="blastoff"

eval "$(starship init zsh)"

# ZSH plugins
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-completions/zsh-completions.plugin.zsh
# source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh
