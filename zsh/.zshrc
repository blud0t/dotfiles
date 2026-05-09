# 1// Powerlevel10k prompts ALWAYS at the start
# 1// p10k's instant prompt for faster startup
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

eval "$(/opt/homebrew/bin/brew shellenv)"


# 2// Zsh history
HISTSIZE=2000
SAVEHIST=2000
setopt INC_APPEND_HISTORY # Save history immediately
setopt SHARE_HISTORY # Share history between all open shells
setopt HIST_IGNORE_DUPS # Ignore duplicate commands
setopt HIST_IGNORE_SPACE # Ignore mistyped space commands


# 3// Environment Variables & PATH
export PATH="$HOME/.local/bin:$PATH"


# 4// Version managers
# / Pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# / Lazy load nvm for speed
export NVM_DIR="$HOME/.nvm"
lazy_load_nvm() {
  unset -f nvm node npm npx
  # Source NVM
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}
nvm() { lazy_load_nvm; nvm "$@" }
node() { lazy_load_nvm; node "$@" }
npm() { lazy_load_nvm; npm "$@" }
npx() { lazy_load_nvm; npx "$@" }


# 5// Aliases
# / Eza with icons (Defined before syntax highlighting to ensure correct parsing)
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -la --icons=auto --group-directories-first'
alias tree='eza --tree --icons=auto'

alias reload-zsh="source ~/.zshrc"
alias edit-zsh="code ~/.zshrc"

alias python="python3"


# 6// Misc
# / bat (best matched with my wezterm colors)
export BAT_THEME="Dracula"

# / pay-respects.
if command -v pay-respects 1>/dev/null 2>&1; then
  eval "$(pay-respects zsh)"
fi

# / Fuzzy finder (fzf) config
if command -v fzf 1>/dev/null 2>&1; then
  eval "$(fzf --zsh)"
  # Switch from find to fd for speed
  export FZF_DEFAULT_OPTS="--color=fg:#CBE0F0,bg:#011628,hl:#B388FF,fg+:#CBE0F0,bg+:#143652,hl+:#B388FF,info:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED,marker:#2CF9ED,spinner:#2CF9ED,header:#2CF9ED"
  export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
  
  _fzf_compgen_path() { fd --hidden --exclude .git . "$1" }
  _fzf_compgen_dir() { fd --type=d --hidden --exclude .git . "$1" }
  
  # fzf configured to use eza
  show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
  export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
  _fzf_comprun() {
    local command=$1
    shift
    case "$command" in
      cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
      export|unset) fzf --preview "eval 'echo \${}'"         "$@" ;;
      ssh)          fzf --preview 'dig {}'                   "$@" ;;
      *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
    esac
  }
fi


# 7// Completions
# The following lines have been added by Docker Desktop to enable Docker CLI completions
if [ -d "$HOME/.docker/completions" ]; then
  fpath=($HOME/.docker/completions $fpath)
fi

# / Initialize Zsh completions
autoload -Uz compinit
compinit -C # Skip cache security checks for faster loading

# 8// Plugin configurations
# / zsh-autosuggestions suggestion color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=cyan'


# 9// Source plugins in strict order
# / zsh-autosuggestions
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# / zsh-syntax-highlighting ALWAYS at the end
source $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh