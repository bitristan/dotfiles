# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# some useful custom function

# Easy extact
extract () {
  if [ -f $1 ] ; then
      case $1 in
          *.tar.xz)    tar xvJf $1    ;;
          *.tar.bz2)   tar xvjf $1    ;;
          *.tar.gz)    tar xvzf $1    ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       unrar e $1     ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xvf $1     ;;
          *.tbz2)      tar xvjf $1    ;;
          *.tgz)       tar xvzf $1    ;;
          *.apk)       unzip $1       ;;
          *.epub)      unzip $1       ;;
          *.xpi)       unzip $1       ;;
          *.zip)       unzip $1       ;;
          *.odt)       unzip $1       ;;
          *.war)       unzip $1       ;;
          *.jar)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)           echo "don't know how to extract '$1'..." ;;
      esac
  else
      echo "'$1' is not a valid file!"
  fi
}
# easy compress - archive wrapper
compress () {
    if [ -n "$1" ] ; then
        FILE=$1
        case $FILE in
        *.tar) shift && tar cf $FILE $* ;;
        *.tar.bz2) shift && tar cjf $FILE $* ;;
        *.tar.gz) shift && tar czf $FILE $* ;;
        *.tgz) shift && tar czf $FILE $* ;;
        *.zip) shift && zip $FILE $* ;;
        *.rar) shift && rar $FILE $* ;;
        esac
    else
        echo "usage: compress <foo.tar.gz> ./foo ./bar"
    fi
}

function pclip() {
    if [ "$OS_NAME" = "CYGWIN" ]; then
        # https://stackoverflow.com/questions/29501860/how-can-bash-read-from-piped-input-or-else-from-the-command-line-argument
        echo -n $(cat) >> /dev/clipboard
    elif [ "$OS_NAME" = "Darwin" ]; then
        pbcopy $@;
    elif hash clip.exe 2>/dev/null; then
        # Linux sub-system on Windows 10
        clip.exe $@
    elif [ -x /usr/bin/xsel ]; then
        xsel -ib $@;
    elif [ -x /usr/bin/xclip ]; then
        xclip -selection c $@;
    else
        echo "Neither xsel or xclip is installed!"
    fi
}

# percol.py can be get from https://github.com/redguardtoo/portable-percol
function fzfnormal {
    if [ -x /usr/bin/fzf ]; then
        # `-e` to turn off fuzzy match
        fzf -e --reverse --cycle -1 -0 -m "$@"
    else
        python $HOME/bin/percol.py "$@"
    fi
}

## File & strings related functions:
# search the file and pop up dialog, then put the full path in clipboard
# usage: baseff (file|dir) keyword
# is used as API instead of user command
function baseff()
{
    local fullpath=$2
    local filename=${fullpath##*./} # remove  ".../" from the beginning

    # - only the filename without path is needed
    # - filename should be reasonable
    if [ "$1" = "file" ] || [ "$1" = "relfile" ];then
        if hash fd 2>/dev/null;then
            local rlt=`fd --full-path -H --type f -E'.git/*' -E'vendor/*' -E'.svn/*' -E'.npm/*' -E'.backups/*' -E'.hg/*' -E'node_modules/*' -I ".*${filename}.*" | fzfnormal`
        else
            local rlt=`find . \( -iwholename '*#' -o -iwholename '*/.backups/*' -o -iwholename '*/deployment/*' -o -iwholename '*/_doc/*' -o -iwholename '*/test/*' -o -iwholename '*/coverage/*' -o -iwholename '*/.gradle/*' -o -iwholename '*~' -o -iwholename '*.swp' -o -iwholename '*/dist/*' -o -iwholename '*.class' -o -iwholename '*.js.html' -o -iwholename '*.elc' -o -iwholename '*.pyc' -o -iwholename '*/bin/*' -o -iwholename '*/.config/*' -o -iwholename '*/vendor/*' -o -iwholename '*/bower_components/*' -o -iwholename '*/node_modules/*' -o -iwholename '*/.svn/*' -o -iwholename '*/.git/*' -o -iwholename '*/.gitback/*' -o -iwholename '*/.npm/*' -o -iwholename '*.sass-cache*' -o -iwholename '*/.hg/*' \) -prune -o -type f -iwholename '*'${filename}'*' -print | fzfnormal`
        fi
    else
        if hash fd 2>/dev/null;then
            local rlt=`fd --full-path -H --type d -E'.git/*' -E'vendor/*' -E'.svn/*' -E'.npm/*' -E'.backups/*' -E'.hg/*' -E'node_modules/*' -I ".*${filename}.*" | fzfnormal`
        else
            local rlt=`find . \( -iwholename '*#' -o -iwholename '*/.backups/*' -o -iwholename '*/deployment/*' -o -iwholename '*/_doc/*' -o -iwholename '*/test/*' -o -iwholename '*/coverage/*' -o -iwholename '*/.gradle/*' -o -iwholename '*~' -o -iwholename '*.swp' -o -iwholename '*/dist/*' -o -iwholename '*.class' -o -iwholename '*.js.html' -o -iwholename '*.elc' -o -iwholename '*.pyc' -o -iwholename '*/bin/*' -o -iwholename '*/.config/*' -o -iwholename '*/vendor/*' -o -iwholename '*/bower_components/*' -o -iwholename '*/node_modules/*' -o -iwholename '*/.svn/*' -o -iwholename '*/.git/*' -o -iwholename '*/.gitback/*' -o -iwholename '*/.npm/*' -o -iwholename '*.sass-cache*' -o -iwholename '*/.hg/*' \) -prune -o -type d -iwholename '*'${filename}'*' -print | fzfnormal`
        fi
    fi
    if [ -z "${rlt}" ];then
        echo ""
    else
        if [ "$1" = "relfile" ]; then
            # use relative path
            echo $rlt
        else
            # convert relative path to full path
            echo $(cd $(dirname $rlt); pwd)/$(basename $rlt)
        fi
    fi
}

## find a file and copy its *nix full path into clipboard
function ff {
    local cli=`baseff file $*`
    echo ${cli}
    echo -n ${cli} | pclip
}

# find&cd a directory. Copy its full path into clipboard
function zz()
{
    local cli=`baseff dir $*`
    if [ -z "${cli}" ];then
        echo "Nothing found!"
    else
        echo ${cli}
        cd ${cli}
        echo -n ${cli} | pclip
    fi
}

# any file on this computer
function aa {
    if [ -z "$1" ]; then
        local cli=`locate / | fzfnormal`
    else
        local cli=`locate "$1" | fzfnormal`
    fi
    echo ${cli}
    echo -n ${cli} | pclip
}

# some more ls aliases
alias g="google-chrome"
alias emacs="emacs -nw"

alias gs="git status --short -b"
alias gb="git branch -vv"
alias gc="git commit"
alias gca="git commit --amend"
alias gd="git diff"
alias gds="git diff --stat"
alias gdc="git diff --cached"
alias gdcs="git diff --cached --stat"
alias grh='git reset --hard HEAD'
alias grh1='git reset --hard HEAD^'
alias grh2='git reset --hard HEAD^^'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# custom environment variables
export ANDROID_HOME=/home/sunting/tools/android-sdk-linux
export PATH=$ANDROID_HOME/platform-tools:$PATH
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/21.1.6352462
export ANDROID_STUDIO_HOME=/home/sunting/tools/android-studio
export PATH=$ANDROID_STUDIO_HOME/bin:$PATH

# disable homebrew auto update
export HOMEBREW_NO_AUTO_UPDATE=1

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/sunting/.sdkman"
[[ -s "/home/sunting/.sdkman/bin/sdkman-init.sh" ]] && source "/home/sunting/.sdkman/bin/sdkman-init.sh"
