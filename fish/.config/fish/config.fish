source ~/.config/fish/cachyos-config.fish
source ~/.config/.env

alias vim="nvim"
alias venv="source .venv/bin/activate.fish"
alias fdate='date +"%d.%m.%Y"'
alias update="brew update && brew upgrade && brew upgrade --cask --greedy && brew cleanup"

if test (uname) = Linux
    alias zapret="$HOME/Desktop/zapret/service.sh"
    alias scrot='scrot "$HOME/Documents/screenshots/%Y-%m-%d_%H-%M-%S.png" -e '\''clipcatctl load -k clipboard -m image/png -f "$f"'\'''
    alias logout="systemctl --user stop graphical-login.target; awesome-client 'awesome.quit()'"
    alias update="sudo pacman -Syu"
    alias foxmarks="foxmarks -f ~/.config/mozilla/firefox/"
    # Custom scripts (stow package `scripts`). Plain set -gx, not
    # fish_add_path: universal state in the tracked fish_variables is
    # shared with the mac, where this PATH order is wrong.
    contains ~/.local/bin $PATH; or set -gx PATH ~/.local/bin $PATH
end
export MANPAGER="nvim +Man! -c 'set nospell'"

function tcd
    cd $(tv dirs -s 'fd -t d --hidden')
end

function tf
    tv files $argv
end

function tmv
    set -l src (tv files)
    if test -z "$src"
        return 1
    end
    set -l dest (tv dirs)
    if test -z "$dest"
        return 1
    end
    mv -i $src $dest
end

function tcp
    set -l src (tv files)
    if test -z "$src"
        return 1
    end
    set -l dest (tv dirs)
    if test -z "$dest"
        return 1
    end
    cp -ri $src $dest
end

function trm
    set -l target (tv files)
    if test -z "$target"
        return 1
    end
    rm -r $target
end

function fp
    realpath $argv[1]
end

function fn
    basename $argv[1]
end

function frp
    set -l full_path (realpath $argv[1])
    string replace "$HOME" "~" "$full_path"
end

tv init fish | source
