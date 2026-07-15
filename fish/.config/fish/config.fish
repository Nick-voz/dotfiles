source ~/.config/fish/cachyos-config.fish
source ~/.config/.env
set -gx MAIL ""

if test -d ~/.config/dmenu-scripts
    fish_add_path ~/.config/dmenu-scripts
    fish_add_path ~/.config/dmenu-scripts/utils/
end

alias vim="nvim"
alias venv="source .venv/bin/activate.fish"
alias fdate='date +"%d.%m.%Y"'

if test (uname) = Linux
    alias zapret="$HOME/Desktop/zapret/service.sh"
    alias scrot='scrot ~/Documents/screenshots/%Y-%m-%d_%H-%M-%S.png'
    alias bookmarks="rofi -show bookmarks -modi 'bookmarks: firefox-bookmarks.py'"
    alias drun="rofi -show combi"
    alias power-menu="$HOME/.config/dmenu-scripts/power.sh"
end
export MANPAGER="nvim +Man! -c 'set nospell'"
export EDITOR=nvim
export TERMINAL=kitty

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

function topdf
    if test (count $argv) -lt 1
        return 1
    end

    set -l input_file $argv[1]
    set -l output_file (string replace -r '\.[^.]+$' '' $input_file).pdf
    set -l extra_args $argv[2..-1]

    set -l has_author 0

    for arg in $extra_args
        if string match -rq '^author=' -- $arg
            set has_author 1
        end
    end

    set -l pandoc_args \
        "$input_file" \
        -o "$output_file" \
        --from markdown \
        --template eisvogel \
        --highlight-style pygments \
        --pdf-engine=xelatex \
        $extra_args

    if test $has_author -eq 0
        set pandoc_args $pandoc_args -M author='Возисов Н.С.'
    end

    begin
        if type -q notify-send
            notify-send -t 2500 "Pandoc" "Converting ..."
            and pandoc $pandoc_args
            and notify-send -t 4000 "Pandoc" "Success: $output_file"
            or notify-send -t 4000 "Pandoc" "Error: $input_file ($status)"
        else if type -q osascript
            osascript -e "display notification \"Converting ...\" with title \"Pandoc\""
            and pandoc $pandoc_args
            and osascript -e "display notification \"Success: $output_file\" with title \"Pandoc\""
            or osascript -e "display notification \"Error: $input_file ($status)\" with title \"Pandoc\""
        else
            pandoc $pandoc_args
        end
    end </dev/null >/dev/null 2>&1 &
    disown
end
