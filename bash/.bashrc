[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias scrot='scrot ~/Documents/screenshots/%Y-%m-%d_%H-%M-%S.png'

PS1='[\u@\h \W]\$ '

source /home/nik/.config/.env
