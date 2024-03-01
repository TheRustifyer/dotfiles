# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"


# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ZSH_THEME="agnoster"
else
    ZSH_THEME="powerlevel10k/powerlevel10k"
fi

HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/

fpath=(./zsh-completions/src $fpath)

plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export TERM=xterm-256color

# You may need to manually set your language environment
export LANG=en_US.UTF-8
# Preferred editor
export EDITOR='nvim'

# Set personal aliases TODO move them to their own mod
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh"
alias vi=nvim

alias .='cd .'
alias ..='cd ..'
alias bashcls='echo "" > ~/.bash_history'
alias cls='clear'
alias ls='ls -F --color=auto --show-control-chars'
alias ll='ls -l'
alias ll.='ls -la'
alias lls='ls -la --sort=size'
alias llt='ls -la --sort=time'
alias rmdir='rm -rf'

alias wincode='cd ~/code'
alias appdata='cd ~/AppData'


if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    alias nvimdir='cd ~/.config/nvim'
    alias rmnvim="find ~/.cache ~/.local -type d -name '*nvim*' -exec rm -rf {} +"
else
    alias nvimdir='cd ~/AppData/Local/nvim'
    alias rmnvim='rm -rf ~/AppData/Local/nvim && rm -rf ~/AppData/Local/nvim-data'
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
alias gpop='git stash pop'
alias ga='git add'
alias gb='git branch'
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gm='git merge'
alias gm='git merge'
alias gmnff='git merge --no-ff'

# For work with my bare git repo for the dotfiles
alias config='git --git-dir=$HOME/.cfg/ --work-tree=$HOME/'


# Adding Clang and LLVM Project to the PATH TODO deprecated. Change the path
# with the git submodule that comes with the dotfiles
export PATH="$HOME/tools/llvm-project/build/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/tools/llvm-project/build/lib:$LD_LIBRARY_PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
