# See https://github.com/nvm-sh/nvm#installation-and-update
if [[ -z "$NVM_DIR" ]]; then
  if [[ -d "$HOME/.nvm" ]]; then
    export NVM_DIR="$HOME/.nvm"
  elif [[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/nvm" ]]; then
    export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
  fi
fi

# Don't try to load nvm if command already available
# Note: nvm is a function so we need to use `which`
which nvm &>/dev/null && return

if [[ -z "$NVM_DIR" ]] || [[ ! -f "$NVM_DIR/nvm.sh" ]]; then
  return
fi

if zstyle -t ':omz:plugins:nvm' lazy && \
  ! zstyle -t ':omz:plugins:nvm' autoload; then
  # Call nvm when first using nvm, node, npm, pnpm, yarn or other commands in lazy-cmd
  zstyle -a ':omz:plugins:nvm' lazy-cmd nvm_lazy_cmd
  eval "
    function vim nvim ng nvm node npm npx pnpm yarn $nvm_lazy_cmd {
      unfunction vim nvim ng nvm node npm npx pnpm yarn $nvm_lazy_cmd
      # Load nvm if it exists in \$NVM_DIR
      [[ -f \"\$NVM_DIR/nvm.sh\" ]] && source \"\$NVM_DIR/nvm.sh\"
      # Load Angular CLI autocompletion.
      if command -v ng >/dev/null 1>&1; then
      	source <(ng completion script)
      fi
      \"\$0\" \"\$@\"
    }
  "
  unset nvm_lazy_cmd
else
  source "$NVM_DIR/nvm.sh"
fi

# Load nvm bash completion
for nvm_completion in "$NVM_DIR/bash_completion"; do
  if [[ -f "$nvm_completion" ]]; then
    # Load bashcompinit
    autoload -U +X bashcompinit && bashcompinit
    # Bypass compinit call in nvm bash completion script. See:
    # https://github.com/nvm-sh/nvm/blob/4436638/bash_completion#L86-L93
    ZSH_VERSION= source "$nvm_completion"
    break
  fi
done

unset nvm_completion
