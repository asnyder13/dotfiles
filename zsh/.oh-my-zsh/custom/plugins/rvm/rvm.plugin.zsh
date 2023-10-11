# Completion
fpath+=("${rvm_path}/scripts/zsh/Completion")

if [[ -z "$RVM_DIR" ]]; then
  if [[ -d "$HOME/.rvm" ]]; then
    export RVM_DIR="$HOME/.rvm"
  elif [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/rvm" ]]; then
    export RVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rvm"
  fi
fi

# Don't try to load rvm if command already available
# Note: rvm is a function so we need to use `which`
which rvm &>/dev/null && return

if [[ -z "$RVM_DIR" ]] || [[ ! -f "$RVM_DIR/rvm.sh" ]]; then 
  return
fi
export PATH="$PATH:$HOME/.rvm/bin"

if zstyle -t ':omz:plugins:rvm' lazy && ! zstyle -t ':omz:plugins:rvm' autoload; then
  # Call rvm when first using rvm ruby bundle rack irb or other commands in lazy-cmd
  zstyle -a ':omz:plugins:rvm' lazy-cmd rvm_lazy_cmd
  eval "
    function rvm ruby bundle rack irb $rvm_lazy_cmd {
      unfunction rvm ruby bundle rack irb $rvm_lazy_cmd
      # Load rvm if it exists in \$RVM_DIR
      [[ -f \"\$RVM_DIR/rvm.sh\" ]] && source \"\$RVM_DIR/rvm.sh\"
      \"\$0\" \"\$@\"
    }
  "
  unset rvm_lazy_cmd
else
  source "$RVM_DIR/scripts/rvm"
fi
