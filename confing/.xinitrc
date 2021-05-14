#!/bin/bash

export GOPATH="$HOME/.go/"
export PATH="$PATH:$HOME/.nimble/bin/"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/.local/share/gem/ruby/3.0.0/bin"

export NNN_COLORS='1234'
export NNN_PLUG='i:imgview;d:dragdrop'

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

export GTK_IM_MODULE='fcitx'
export QT_IM_MODULE='fcitx'
export SDL_IM_MODULE='fcitx'
export XMODIFERS='@im=fcitx'

export EDITOR="nvim"
export BROWSER="qutebrowser"
export SHELL="fish"
export TERMINAL="alacritty"
export PAGER="less"
export DMENU="dmenu"

export LESSHISTFILE=-

setxkbmap pl -option caps:super
xcape -e 'Shift_L=Escape;Super_L=BackSpace'

picom &
transmission-daemon &
xwallpaper --zoom ~/.config/wallpaper
slstatus &
fcitx -d &

while true; do
    dwm
done
