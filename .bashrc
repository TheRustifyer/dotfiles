# Dotfiles bare repo alias
alias config='git --git-dir="$HOME"/.cfg/ --work-tree="$HOME"' 

# Set the default shell when bash is invoked
if [ -t 1 ]; then
  eval "$(starship init bash)"
fi
. "$HOME/.cargo/env"
