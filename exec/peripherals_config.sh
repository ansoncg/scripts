#!/bin/bash

show_help() {
        printf "\
Options:
    -kb, --keyboard
        caps: Enable capslock.
        nocaps: Disable capslock and use it as the copyright symbol.
        lang: Change keyboard layout.
        k380: My k380 config.
    -mn, --monitor
        single: Single laptop monitor.
        dual-dual: Dual monitor with both on.
        dual-single: Dual monitor with only HDMI on.
    -ms, --mouse
        TODO
    -h, --help
        Show this help.
"
}

config_keyboard() {
    case "$1" in
        caps)
            setxkbmap -option
            ;;
        nocaps)
            setxkbmap -option caps:none
            xmodmap -e "keycode 66 = copyright"
            ;;
        lang)
            if [ "$2" ] ; then
                setxkbmap "$2"
            fi
            ;;
        k380)
            setxkbmap us
            setxkbmap -option caps:none
            xmodmap -e "keycode 66 = copyright"
            xset r rate 300 50
            solaar config k380 fn-swap False > /dev/null 2>&1 &
            ;;
        *)
            show_help
            ;;
    esac
}

config_monitor() {
    case "$1" in
        single)
            xrandr \
                --output eDP1 \
                --mode 1366x768 \
                --rotate normal \
                --output HDMI2 \
                --off \
            ;;
        dual-single)
            xrandr \
                --output eDP1 \
                --off \
                --output DP1 \
                --off \
                --output HDMI2 \
                --primary \
                --mode 1920x1080 \
                --pos 0x0 \
                --rotate normal
            ;;
        dual-dual)
            xrandr \
                --output eDP1 \
                --mode 1366x768 \
                --pos 1920x0 \
                --rotate normal \
                --output DP1 \
                --off \
                --output HDMI2 \
                --primary \
                --mode 1920x1080 \
                --pos 0x0 \
                --rotate normal
            ;;
        *)
            show_help
            exit
    esac
    nitrogen --restore > /dev/null 2>&1
    exec $SCRIPTS_PATH/launch_polybar.sh > /dev/null 2>&1
}

config_mouse() {
    case "$1" in
        *)
            show_help
            ;;
    esac

}

case "$1" in
    -kb|--keyboard)
        config_keyboard "$2" "$3"
        ;;
    -mn|--monitor)
        config_monitor "$2"
        ;;
    -ms|--mouse)
        config_mouse "$2"
        ;;
    *|-h|--help)
        show_help
        ;;
esac
