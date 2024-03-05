# Ethan's bash profile

# if not running interactively then don't do anything
[[ $- != *i* ]] && return;

export EDITOR=vim;
# vim profile ~ https://raw.githubusercontent.com/amix/vimrc/master/vimrcs/basic.vim

# -- bash prompt settings --

function ps1hostname {
    unset PS1HOSTNAME
    PS1HOSTNAME=$(hostname)
    [[ -n "$HOSTNAMEALIAS" ]] && PS1HOSTNAME="$HOSTNAMEALIAS"
    printf "${PS1HOSTNAME%%.*}"
}; export -f ps1hostname;

function ps1gitbranch {
    unset PS1GITBRANCH
    PS1GITBRANCH=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    [[ -n "$PS1GITBRANCH" ]] && printf " ($PS1GITBRANCH)"
}; export -f ps1gitbranch;

export PS1='\e[0;36m\][\t \d] \e[0;35m\]`ps1hostname`:\e[0;33m\]`pwd`\e[0;32m\]`ps1gitbranch`\e[0;36m\] \e[m\]\n\[$(tput sgr0)\]';
#export PS1='\e[0;36m\][\t \d] \e[0;35m\]`ps1hostname`:\e[0;33m\]`pwd`\e[0;32m\]`ps1gitbranch`\e[0;36m\] \u\\$\e[m\]\n\[$(tput sgr0)\]';

# -- history settings --

export HISTTIMEFORMAT="[%T %F] ";
export HISTCONTROL=ignoreboth;

# -- grep settings --

# obsolete?
#export GREP_OPTIONS="--binary-files=without-match --color=auto";

# -- bash aliases and functions --

alias printfunction="declare -f ";
function expandalias {
    [[ -n $(alias | grep "^alias $1=") ]] && alias "$1" | cut -d\' -f2
}; export -f expandalias;
function xpnd { expandalias "$@"; }; export -f xpnd;

# mgmt aliases
alias S="sudo ";
alias t="time ";
alias w="watch ";
alias h="history ";
alias hg="history | grep ";
alias view="vim -R ";
alias mysql="mysql --i-am-a-dummy ";
alias rmf="rm -rf ";
alias mkdir="mkdir -pv ";
alias rsync="rsync -Ph ";

if [[ $(uname) == "Linux" ]]; then
alias ls="ls -1 -FH --color=auto ";
elif [[ $(uname) == "Darwin" ]]; then
alias ls="ls -1 -FH -G ";
else
alias ls="ls -1 -FH ";
fi

# ps aliases
alias psa="ps aux | head -1 && ps aux | grep ";
alias psaw="ps aux | head -1 && ps aux | grep \"^$(whoami) \" --color=never ";
alias psas="ps aux | grep ";
alias psaws="ps aux | grep \"^$(whoami) \" --color=never ";
alias cpuuse="ps aux | grep \"^$(whoami) \" | awk \"{sum+=\\\$3}END{print sum}\" ";

# run last command as sudo ~ usage: please/pls
function please {
    sudo $(history 2 | cut -d "]" -f2- | cut -c2- | head -1)
}; export -f please;
function pls { please "$@"; }; export -f pls;

# clear history
function clearhistory {
    echo "" > $HISTFILE
}; export -f clearhistory;

# cd .. an arbitrary number of times ~ usage: cdup <number>
function cdup {
    for ((i = 1; i <= "${1:-1}"; i++)); do
        cd ../
    done
}; export -f cdup;

# mkdir && cd ~ usage: mkcd <dir>
function mkcd {
    mkdir -pv "$1" && cd "$1"
}; export -f mkcd;

# create back up of file ~ usage: backup/bkup <file to back up>
function backup {
    cp -i "$1" "$1.$(date +%Y%m%d_%H%M%S)"
}; export -f backup;
function bkup { backup "$@"; }; export -f bkup;

# find string matches only in a specified column ~ usage: matchcol <string to match> <file to search> <column num (default 0/all)>
function matchcol {
    LC_ALL=C awk -F $"\t" "\$$1 ~ /$2/ {print \$0}" $3
}; export -f matchcol;

# find string matches only in a specified column and print linenum ~ usage: matchcol <string to match> <file to search> <column num (default 0/all)>
function matchcoln {
    LC_ALL=C awk -F $"\t" "\$$1 ~ /$2/ {print NR\":\"\$0}" $3
}; export -f matchcoln;

# print the nth line of a file ~ usage: line <num> <file>
function line {
    sed "$1q;d" "$2"
}; export -f line;

# print lines between given values from a file ~ usage: lines <start-num> <end-num> <file>
function lines {
    sed -n "$1,$2p" "$3"
}; export -f lines;

# count number of lines in a file ~ usage: linecount/lcnt <file>
function linecount {
    wc -l "$1" | cut -d " " -f1
}; export -f linecount;
function lcnt { linecount "$@"; }; export -f lcnt;

# count number of bytes in a file ~ usage: bytecount/bcnt <file>
function bytecount {
    wc -c "$1" | cut -d " " -f1
}; export -f bytecount;
function bcnt { bytecount "$@"; }; export -f bcnt;

# count number of chars in a file ~ usage: charcount/ccnt <file>
function charcount {
    wc -m "$1" | cut -d " " -f1
}; export -f charcount;
function ccnt { charcount "$@"; }; export -f ccnt;

# count number of files in a directory ~ usage: filecount/fcnt <dir (default: ./)>
function filecount {
    echo $(find "${1:-./}" -type f | wc -l)
}; export -f filecount;
function fcnt { filecount "$@"; }; export -f fcnt;

alias dh="du -h ";

# size of folder only ~ usage: dhc <dir> <additional du options>
function dhc {
    du -hc "$@" | tail -1 | cut -f1
}; export -f dhc;

# size of folder and subfolders sorted ~ usage: dhs <dir> <additional du options>
function dhs {
    du -h "$@" | sort -h
}; export -f dhs;

# find file in dir ~ usage: findfile/ffind <name of file> <dir to search (default: ./)>
function findfile {
    find "${2:-./}" -iname "*$1*"
}; export -f findfile;
function ffind { findfile "$@"; }; export -f ffind;

# search for string in files in current directory ~ usage: searchinfiles/sif <string to search> <additional git options>
function searchinfiles {
    grep -r -n ${@:2} --exclude-dir=.git --exclude-dir=node_modules "$1" ./
}; export -f searchinfiles;
function sif { searchinfiles "$@"; }; export -f sif;

# replace string in files in current directory ~ usage: replaceinfiles/rif <string to replace> <replacement string>
function replaceinfiles {
    find ./ ${@:3} -type f -exec sed -i "s|$1|$2|g" {} +
}; export -f replaceinfiles;
function rif { replaceinfiles "$@"; }; export -f rif;

# print date of latest edit in a folder ~ usage: lastedit <dir (default: ./)>
function lastedit {
    find "${1:-./}" -type f -exec stat \{} --printf="%y\n" \; | sort -nr | head -1 | cut -c1-19
}; export -f lastedit;

# provides a sequence of numbers that has an equation applied to sequential numbers starting from 1 ~ usage: sequenceequation/seqeq <length of sequence> <equation to apply with "x" as variable>
# example: `seqeq 5 "(x*3)+5"` produces `8 11 14 17 20`
function sequenceequation {
    echo $(for x in $(seq $1); do seqeq_x=$(($2)); echo $seqeq_x; done)
}; export -f sequenceequation;
function seqeq { sequenceequation "$@"; }; export -f seqeq;

# sorts a file in place ~ usage: sortinplace/sip <file> <additional sort options>
function sortinplace {
    sort "${@:2}" -o "$1" "$1"
}; export -f sortinplace;
function sip { sortinplace "$@"; }; export -f sip;

# says whether or not every line in a file is unique ~ usage: isuniq <file>
function isuniq {
    if [[ $(< "$1" wc -l) == $(sort "$1" | uniq | wc -l) ]]; then
        echo "yes"
    else
        echo "no"
    fi
}; export -f isuniq;

# returns 0 when a file is unique (trailing "s" for silent) ~ usage: isuniqsilent/isuniqs <file>
function isuniqsilent {
    if [[ $(< "$1" wc -l) == $(sort "$1" | uniq | wc -l) ]]; then
        return 0
    else
        return 1
    fi
}; export -f isuniqsilent;
function isuniqs { isuniqsilent "$@"; }; export -f isuniqs;

# easier way of running comm to find lines shared by both files ~ usage: vennmiddle <file1> <file2>
function vennmiddle {
    comm -12 <(sort "$1" | uniq) <(sort "$2" | uniq)
}; export -f vennmiddle;

# easier way of running comm to find lines unique to first file ~ usage: vennleft <file1> <file2>
function vennleft {
    comm -23 <(sort "$1" | uniq) <(sort "$2" | uniq)
}; export -f vennleft;

# easier way of running comm to find lines unique to second file ~ usage: vennright <file1> <file2>
function vennright {
    comm -13 <(sort "$1" | uniq) <(sort "$2" | uniq)
}; export -f vennright;

# like vennleft but in preserved order and keeps duplicates ~ usage: vennleft+ <file1> <file2>
function vennleft+ {
    LC_ALL=C awk 'FNR==NR{a[$0]; next} $0 in a' <(comm -23 <(sort "$1" | uniq) <(sort "$2" | uniq)) "$1"
}; export -f vennleft+;

# like vennright but in preserved order and keeps duplicates ~ usage: vennright+ <file1> <file2>
function vennright+ {
    LC_ALL=C awk 'FNR==NR{a[$0]; next} $0 in a' <(comm -13 <(sort "$1" | uniq) <(sort "$2" | uniq)) "$2"
}; export -f vennright+;

# sum all numbers in a specified column ~ usage: sumcol <column number> <file>
function sumcol {
    awk "{sum+=\$$1}END{print sum}" "$2"
}; export -f sumcol;

# convert to raw binary ~ usage: tobinary <file>
function tobinary {
    xxd -c16 -b "$1" | cut -d " " -f2-17 | tr -d " " | tr -d "\n"
}; export -f tobinary;

# rerun last command with certain string replaced ~ usage: rerunswitch <string-to-be-replaced> <replacement-string>
function rerunswitch {
    rerunswitch_last_cmd_raw=$(history 2 | head -1 | cut -d "]" -f2- | cut -c2-)
    bash -c "$(echo "$rerunswitch_last_cmd_raw" | sed "s/$1/$2/g")"
}; export -f rerunswitch;

# save command used to generate file (must be separate command immediately following command to save) ~ usage: savefilegen
function savefilegen {
    savesrc_last_cmd_raw=$(history 2 | head -1 | cut -d "]" -f2- | cut -c2-)
    savesrc_last_cmd=$(echo "$savesrc_last_cmd_raw" | grep ">" --color=never | rev | cut -d ">" -f2- | rev)
    savesrc_last_output_name=$(echo "$savesrc_last_cmd_raw" | grep ">" --color=never | rev | cut -d ">" -f1 | rev | sed -e "s/^[ \t]*//")
    if [[ -n $savesrc_last_output_name ]]; then
        echo "$savesrc_last_output_name: $savesrc_last_cmd"
        echo "$savesrc_last_cmd" > ${savesrc_last_output_name}.src_cmd
    else
        echo "no output file found"
    fi
}; export -f savefilegen;

# kill all jobs with string (use with caution) ~ usage: pskill <string>
function pskill {
    kill -9 $(ps aux | grep "$1" | awk '{print $2}')
}; export -f pskill;

# -- aliases for this file --

alias srcbashp="source <(curl -sN https://raw.githubusercontent.com/eacoeytaux/libs/master/bash_profile)";
alias viewbashp="view <(curl -sN https://raw.githubusercontent.com/eacoeytaux/libs/master/bash_profile)";
alias catbashp="curl -sN https://raw.githubusercontent.com/eacoeytaux/libs/master/bash_profile";

