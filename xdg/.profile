# ~/.profile — managed by dotfiles (`stow xdg`).

: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
export XDG_CONFIG_HOME XDG_DATA_HOME XDG_STATE_HOME XDG_CACHE_HOME
# NOTE: XDG_RUNTIME_DIR is set by systemd/pam_systemd — never export it here.

# Custom scripts (stow package `scripts`) — Linux sessions only; the mac
# keeps its own PATH order.
if [ "$(uname)" = Linux ]; then
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) PATH="$HOME/.local/bin:$PATH" ;;
    esac
    export PATH
fi

# Default applications.
export BROWSER=firefox
export EDITOR=/usr/bin/nvim
export TERMINAL=kitty

# Qt styling: follow the GTK3 theme (catppuccin-mocha) via the qgtk3
# platformtheme. Covers Qt5/Qt6 system apps and Zoom's Qt6 bundle.
export QT_QPA_PLATFORMTHEME=gtk3
