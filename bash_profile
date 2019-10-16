# if not running interactively then don't do anything
[[ $- != *i* ]] && return

export PS1="\e[0;36m\][\t \d] ${HOSTNAMEALIAS%%.*}:\w \u\\$\e[m\]\n\[$(tput sgr0)\]"
export HISTTIMEFORMAT="[%T %F] "
export HISTCONTROL="ignoreboth"
export EDITOR=vim
export GREP_OPTIONS="--color=auto"

#bash aliases
alias S="sudo"
alias view="vim -R"
alias t="time"
alias la="ls -laF"
alias lh="ls -laFh"
alias lr="ls -laFhR"
alias rmf="rm -rf"
alias mkdir="mkdir -pv"
alias dh="du -h"
alias rsync="rsync -Ph"
alias psa="ps aux | head -1 && ps aux | grep"
alias psaw="ps aux | head -1 && ps aux | grep ^$(whoami)"
alias h="history"
alias hg="history | grep"
alias bashp="vim ~/.bashrc.user"
alias bashs="source ~/.bashrc.user"
alias bashps="vim ~/.bashrc.user; source ~/.bashrc.user"
alias bashc="cat ~/.bashrc.user"
alias bashv="view ~/.bashrc.user"
alias vimp="vim ~/.vimrc"
alias vimc="cat ~/.vimrc"

# bash functions
function please {
    sudo $(history 2 | cut -d ']' -f2 | cut -c2- | head -1)
}
function cdl {
    cd "$1" && ls -laFh
}
function cdup {
    cdup_count=$1
    if [[ -z $cdup_count ]]; then
            cdup_count="1"
    fi
    for ((i = 1; i <= $cdup_count; i++)); do
        cd ../
    done
}
function mkcd {
    mkdir -pv "$1" && cd "$1"
}
function fcnt {
    fcnt_dir=$1
    if [[ -z $fcnt_dir ]]; then
            fcnt_dir="."
    fi
    echo $(ls "$fcnt_dir" | wc -l)
}
function dhs {
    du -h $@ | sort -h
}

function fhere {
    find . -iname "*$1*"
}
function ffind {
    find $1 -iname "*$2*"
}
function lastedit {
    find $1 -type f -exec stat \{} --printf="%y\n" \; | sort -nr | head -1
}
function pskill {
    kill -9 $(ps aux | grep $1 | awk '{print $2}')
}
function sumcol {
    awk "{sum+=\$$1}END{print sum}" $2
}
function binary {
    xxd -c16 -b $1 | cut -d' '-f2-17 | tr -d' '| tr -d'\n'
}

# git aliases
alias gs="git status"
alias gb="git branch"
alias gc="git checkout"
alias gg="git grep --color=auto -n -i"
alias gd="git diff"

# git functions
function gitsquish {
    branch_to_rebase=$1
    if [[ -z $branch_to_rebase ]]; then
            branch_to_rebase=$(gitcurr)
    fi
    git checkout $branch_to_rebase
    git pull
    num_to_squash=$(git cherry -v master | wc -l)
    git rebase -i HEAD~$num_to_squash
}
function gitrebase {
    branch_to_rebase=$1
    if [[ -z $branch_to_rebase ]]; then
            branch_to_rebase=$(gitcurr)
    fi
    git checkout master
    git fetch -a
    git pull
    git checkout $branch_to_rebase
    git fetch origin
    git rebase origin/master
}
function gitcurr {
    git branch | grep "\* " | cut -d '*' -f2 | cut -c2-
}
function gitupdate {
    git commit -am 'msg'
    git rebase -i HEAD~2
    git push origin -f $(gitcurr)
}
