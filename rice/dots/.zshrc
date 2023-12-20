# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

# Comments for shellcheck to shut the fuck up about my rc files
# shellcheck source=/dev/null
# shellcheck disable=SC2034
# shellcheck disable=SC2139

# if problems arise change $USER to ${(%):-%n}
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$USER.zsh"
fi

# Set up the prompt
autoload -Uz promptinit
promptinit
prompt adam1

setopt histignorealldups sharehistory autocd autopushd pushdignoredups

# VI mode
bindkey -v
KEYTIMEOUT=1

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Autocompletion
autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
#if problems arise change "$(echo $LS_COLORS | tr : ' ')" into ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' list-colors "$(echo "$LS_COLORS" | tr : " ")"
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command "ps -u $USER -o pid,%cpu,tty,cputime,cmd"

source ~/opt/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# PATH extensions
export PATH="$PATH:$HOME/opt/nvim/bin"
export PATH="$PATH:$HOME/opt/TEXLIVE/2023/bin/x86_64-linux"
export PATH="$PATH:$HOME/.local/bin"

# Keyboard tweaks
setxkbmap -option caps:swapescape

#                       #
#       ALIASES         #
#                       #
alias ls="LC_COLLATE=C ls --color=tty -lh --group-directories-first"
alias la="ls -A"
alias grep="grep --color=auto"
alias diff="diff --color"
alias vi="nvim"
alias reload="source $HOME/.zshrc"
alias feh="feh --scale-down --geometry +1920+1080 --image-bg style"
alias mpv="mpv --loop"
alias rename="rename -v"

# Suffixes
alias -s pdf="evince"
alias -s {png,jpg,jpeg,webp,gif}="feh"
alias -s {txt,md}="vi"
alias -s {ods,xlsx}="libreoffice --calc"
alias -s {odf,docx}="libreoffice --writer"
alias -s {flac,wav,mp3,m3u,ogg,opus}="mpv"
alias -s {mp4,mkv,avi}="vlc"

# Globals
alias -g zshrc="$HOME/.zshrc"

# Python
alias py="python3"
alias pip="pip3"

# Git
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gpush="git push"
alias gpull="git pull"
alias gf="git fetch"
alias gd="git diff"

# VSCode
vsc() {
    local switch="${1}"
    local profile=""
    local vscode=/usr/bin/code

    case $switch in
    python | py)
        profile="Python"
        ;;
    c | cpp | cxx)
        profile="C++"
        ;;
    shell | bash | sh)
        profile="Bash"
        ;;
    web | js | ts)
        profile="Webdev"
        ;;
    tex | latex)
        profile="Latex"
        ;;
    *)
        $vscode "$1" --profile Default
        return
        ;;
    esac
    $vscode "$2" --profile "$profile"
}

# Tex
alias texget="tlmgr"

# Remote
alias rsync="rsync -avh --progress"
alias psh="ssh phone"

# Traversal
alias d="dirs -v | head -10"
alias 1="cd -"
alias 2="cd -2"
alias 3="cd -3"
alias 4="cd -4"
alias 5="cd -5"
alias 6="cd -6"
alias 7="cd -7"
alias 8="cd -8"
alias 9="cd -9"
alias ...="cd ../.."
alias ....="cd ../../.."
mkcd() { mkdir "${1}" && cd "${1}" || return; }

fcd() { # Finds dirs in $1 and pipes list into fzf
    if [[ -z "$1" ]]; then DIR="$HOME"; else DIR="$1"; fi
    cd "$(find "${DIR}" -type d | fzf)" || return
}

# Perl rename
tolower() { rename -v "y/A-Z/a-z/" "$@"; }
toupper() { rename -v "y/a-z/A-Z/" "$@"; }

# Source plugins
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
