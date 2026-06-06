source ~/.config/fish/cachyos-config.fish
source ~/.config/.env

fish_add_path ~/.config/dmenu-scripts
fish_add_path ~/.config/dmenu-scripts/utils/

alias vim="nvim"
alias zapret="$HOME/Desktop/zapret/service.sh"
alias venv="source .venv/bin/activate.fish"
alias scrot='scrot ~/Documents/screenshots/%Y-%m-%d_%H-%M-%S.png'
alias bookmarks="rofi -show bookmarks -modi 'bookmarks: firefox-bookmarks.py'"
alias drun="rofi -show combi"
alias power-menu="$HOME/.config/dmenu-scripts/power.sh"
alias fdate='date +"%d.%m.%Y"'
export MANPAGER="nvim +Man! -c 'set nospell'"
export EDITOR=nvim
export TERMINAL=kitty

function cdt
    cd $(tv dirs -s 'fd -t d --hidden')
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

    for i in (seq (count $extra_args))
        set -l arg $extra_args[$i]
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

    pandoc $pandoc_args &
    set -l pid $last_pid

    sh -c '
    input_file=$1
    output_file=$2
    shift 2

    notify-send -t 2500 "Pandoc" "Converting ..."
    pandoc "$@"
    code=$?
    if [ $code -eq 0 ]; then
        notify-send -t 4000 "Pandoc" "Success: $output_file"
    else
        notify-send -t 4000 "Pandoc" "Error: $input_file ($code)"
    fi
    exit $code
' sh "$input_file" "$output_file" $pandoc_args >/dev/null 2>&1 &

    disown
end
