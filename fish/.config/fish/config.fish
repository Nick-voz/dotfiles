source ~/.config/fish/cachyos-config.fish
source ~/.config/.env

alias vim="nvim"
alias venv="source .venv/bin/activate.fish"
alias fdate='date +"%d.%m.%Y"'

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

if test (uname) = Darwin
    eval (/opt/homebrew/bin/brew shellenv fish)
    # Homebrew 7 ships "ask mode" on by default: brew install/upgrade
    # prints the plan and prompts y/N. This turns the default off; an
    # explicit --ask still prompts.
    set -gx HOMEBREW_NO_ASK 1
    # Never run brew itself under sudo: the prefix is user-owned and
    # root would leave files that break the next run. The only real
    # stop is the sudo ticket pkg-casks ask for: authenticate up
    # front and export HOMEBREW_SUDO_CHECKED so brew skips its
    # startup `sudo --reset-timestamp` and reuses the ticket.
    function update
        sudo -v; or return 1
        set -lx HOMEBREW_SUDO_CHECKED 1
        brew update && brew upgrade && brew upgrade --cask --greedy && brew cleanup
    end
end
