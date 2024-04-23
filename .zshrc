# HOME as $HOME, pls ;)
export HOME="$HOME"

HIST_STAMPS="dd.mm.yyyy"

# User configuration
export TERM=xterm-256color

# You may need to manually set your language environment
export LANG=en_US.UTF-8
# Preferred editor
export EDITOR='nvim'

autoload -Uz compinit && compinit
plugins=(git)

# Set personal aliases
# TODO: move them to their own mod
alias me='cd $HOME'
alias vi=nvim
alias lg='lazygit'
alias lgd='lazygit --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias .='cd .'
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

alias zshconf="nvim ~/.zshrc"
alias zellijconf='nvim ~/.config/zellij/config.kdl'
alias wezconf='nvim ~/.wezterm.lua'

## Custom tools
#

# Using `bat` as a better `cat`
alias cat='bat'

# Overpowering the access to edit my projects, thanks to the `Zellij` layouts
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias wzork='alacritty -e zellij --layout zork'
    alias wzero='alacritty -e zellij --layout zero'
else
    alias wzork='alacritty -e zellij --layout zork_win'
    alias wzero='alacritty -e zellij --layout zero_win'
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias nvimconf='cd ~/.config/nvim && nvim'
    alias nvimdir='cd ~/.config/nvim'
    alias rmnvim="find ~/.cache ~/.local -type d -name '*nvim*' -exec rm -rf {} +"
    alias alaconf='nvim ~/.config/alacritty/alacritty.toml'
else
    alias wincode='cd ~/code'
    alias appdata='cd ~/AppData'

    alias nvimconf='cd ~/AppData/Local/nvim && nvim'
    alias nvimdir='cd ~/AppData/Local/nvim'
    alias rmnvim='rm -rf ~/AppData/Local/nvim && rm -rf ~/AppData/Local/nvim-data'

    alias alaconf='nvim ~/AppData/Roaming/alacritty/alacritty.toml'
fi

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

export PATH="$HOME/third-party/llvm-project/build/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/third-party/llvm-project/build/lib:$LD_LIBRARY_PATH"

# Having GitHub CLI avaliable on path on Windows
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    export PATH="$HOME/gh-cli/bin:$PATH"
fi

# Starship!
function set_win_title() {
    echo -ne "\033]0; $(basename "$PWD") \007"
}
starship_precmd_user_func="set_win_title"

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

