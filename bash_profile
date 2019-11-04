# Ethan's bash profile

# if not running interactively then don't do anything
[[ $- != *i* ]] && return

export PS1="\e[0;36m\][\t \d] \e[0;35m\]\h\e[0;36m\]:\w \u\\$\e[m\]\n\[$(tput sgr0)\]"
[[ -n "$HOSTNAMEALIAS" ]] && export PS1="\e[0;36m\][\t \d] \e[0;35m\]${HOSTNAMEALIAS%%.*}\e[0;36m\]:\w \u\\$\e[m\]\n\[$(tput sgr0)\]"

export HISTTIMEFORMAT="[%T %F] "
export HISTCONTROL=ignoreboth
export EDITOR=vim

# -- bash aliases and functions --

function expandalias {
    alias "$1" | cut -d\' -f2
}
function xpnalias {
    expandalias "$1"
}

alias S="sudo "
alias view="vim -R"
alias t="time "
alias w="watch "
alias ls="ls -1 -aF --color=auto "
alias lh="ls -laFh --color=auto "
alias rmf="rm -rf "
alias mkdir="mkdir -pv "
alias dh="du -h "
alias rsync="rsync -Ph "
alias psa="ps aux | head -1 && ps aux | grep "
alias psaw="ps aux | head -1 && ps aux | grep ^$(whoami) "
alias h="history "
alias hg="history | grep "

# run last command as sudo ~ usage: please
function please {
    sudo $(history 2 | cut -d ']' -f2 | cut -c2- | head -1)
}

# cd && ls ~ usage: cdl <dir>
function cdls {
    cd "$1" && ls -1 -aF --color=auto
}

# cd && lh ~ usage: cdl <dir>
function cdlh {
    cd "$1" && ls -1 -laFh --color=auto
}

# cd .. an arbitrary number of times ~ usage: cdup <number>
function cdup {
    for ((i = 1; i <= "${1:-1}"; i++)); do
        cd ../
    done
}

# mkdir && cd ~ usage: mkcd <dir>
function mkcd {
    mkdir -pv "$1" && cd "$1"
}

# create back up of file ~ usage: bkup <file to back up>
function bkup {
    cp -i "$1" ".$1.bkup_$(date +%Y%m%d_%H%M%S)"
}

# count number of files in a directory ~ usage: filecount <dir (default: ./)>
function filecount {
    echo $(find "${1:-./}" -type f | wc -l)
}
alias fcnt="filecount "

# size of folders sorted ~ usage: dhs <dir> <additional du options>
function dhs {
    du -h "$@" | sort -h
}

# find file in dir ~ usage: fhere <name of file> <dir to search (default: ./)>
function ffind {
    find "${2:-./}" -iname "*$1*"
}

# search for string in files in current directory ~ usage: sif <string to search> <additional git options>
function sif() {
    grep -r -n "${@:2}" --exclude-dir=.git --exclude-dir=node_modules "$1" ./
}

# replace string in files in current directory ~ usage: rif <string to replace> <replacement string>
function rif() {
    find ./ -type f -exec sed -i "s|$1|$2|g" {} +
}

# print date of latest edit in a folder ~ usage: lastedit <dir (default: ./)>
function lastedit {
    find "${1:-./}" -type f -exec stat \{} --printf="%y\n" \; | sort -nr | head -1
}

# kill all jobs with string (use with caution) ~ usage: pskill <string>
function pskill {
    kill -9 $(ps aux | grep "$1" | awk '{print $2}')
}

# sum all numbers in a specified column ~ usage: sumcol <column number> <file>
function sumcol {
    awk "{sum+=\$$1}END{print sum}" "$2"
}

# convert to raw binary
function binary {
    xxd -c16 -b "$1" | cut -d' '-f2-17 | tr -d' '| tr -d'\n'
}

# save command used to generate file (must be separate command immediately following command to save) ~ usage: savesrc
function savesrc {
    savesrc_last_cmd=$(history | tail -2 | head -1 | cut -c 30-) # cut first 30 chars to remove date from history line
    savesrc_last_output_name=$(echo "$savesrc_last_cmd" | grep ">" | rev | cut -d'>' -f1 | rev | sed -e 's/^[ \t]*//')
    if [[ -n $savesrc_last_output_name ]]; then
        echo "$savesrc_last_output_name: $savesrc_last_cmd"
        echo "$savesrc_last_cmd" > ${savesrc_last_output_name}.src_cmd
    else
        echo "no output file found"
    fi
}

# -- git aliases and functions --

export GREP_OPTIONS="--color=auto"

alias gs="git status "
alias gb="git branch "
alias gc="git checkout "
alias gg="git grep --color=auto -n -i "
alias gd="git diff "

# git rebase all commits into one
function gitsquish {
    branch_to_rebase="${1:-$(gitcurr)}"
    git checkout "$branch_to_rebase"
    git pull
    num_to_squash=$(git cherry -v master | wc -l)
    git rebase -i HEAD~$num_to_squash
}

# auto git rebase
function gitrebase {
    branch_to_rebase="${1:-$(gitcurr)}"
    git checkout master
    git fetch -a
    git pull
    git checkout "$branch_to_rebase"
    git fetch origin
    git rebase origin/master
}

# current git branch
function gitcurr {
    git branch | grep "\* " | cut -d '*' -f2 | cut -c2-
}

# nearly-auto rebase change into last commit and force push
function gitupdate {
    git commit -am 'msg'
    git rebase -i HEAD~2
    git push origin -f $(gitcurr)
}

# alias for this file

alias srcbashp="source <(curl -sN https://raw.githubusercontent.com/eacoeytaux/libs/master/bash_profile) "
alias viewbashp="view <(curl -sN https://raw.githubusercontent.com/eacoeytaux/libs/master/bash_profile) "
alias catbashp="curl -sN https://raw.githubusercontent.com/eacoeytaux/libs/master/bash_profile "
