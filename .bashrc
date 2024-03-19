# Set the default shell when bash is invoked
if [ -t 1 ]; then
  eval "$(starship init bash)"
fi
