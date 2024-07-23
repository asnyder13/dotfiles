# Completion

# See https://github.com/rvm-sh/rvm#installation-and-update
if [[ -z "$RVM_DIR" ]]; then
  if [[ -d "$HOME/.rvm" ]]; then
    export RVM_DIR="$HOME/.rvm"
  elif [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/rvm" ]]; then
    export RVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rvm"
  fi
fi

if [[ -z "$RVM_DIR" ]] || [[ ! -f "$RVM_DIR/scripts/rvm" ]]; then
  return
fi

fpath+=("$RVM_DIR/scripts/zsh/Completion")

if zstyle -t ':omz:plugins:rvm' lazy; then
  # Call rvm when first using rvm, node, npm, pnpm, yarn or other commands in lazy-cmd
  zstyle -a ':omz:plugins:rvm' lazy-cmd rvm_lazy_cmd
  rvm_lazy_cmd=(rvm ruby rack bundle irb $rvm_lazy_cmd) # default values
  eval "
    function $rvm_lazy_cmd {
      for func in $rvm_lazy_cmd; do
        if (( \$+functions[\$func] )); then
          unfunction \$func
        fi
      done
      # Load rvm if it exists in \$RVM_DIR
      [[ -f \"\$RVM_DIR/scripts/rvm\" ]] && source \"\$RVM_DIR/scripts/rvm\"
      \"\$0\" \"\$@\"
    }
  "
  unset rvm_lazy_cmd
else
  source "$RVM_DIR/scripts/rvm"
fi
