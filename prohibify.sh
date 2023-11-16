#!/bin/bash

# Copyright (C) 2023 paperbenni <paperbenni@gmail.com>
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

version="0.0.2"

function show_help {
    echo "Usage: prohibify.sh [OPTION]..."
    echo "Periodically kill programs in a blocklist to stop distractions."
    echo ""
    echo "Options:"
    echo "  --help     display this help and exit"
    echo "  --version  output version information and exit"
    echo ""
    echo "Example blocklist:"
    echo "  firefox:partial:force"
    echo "  solitaire"
    echo "  chrome:force"
    echo "The first line will force kill any process with 'firefox' in its name."
    echo "The second line will only kill processes named exactly 'solitaire'."
    echo "The third line will force kill any process with 'chrome' in its name."
}

while (("$#")); do
    case "$1" in
    --help)
        show_help
        exit 0
        ;;
    --version)
        echo "prohibify version $version"
        exit 0
        ;;
    *)
        shift
        ;;
    esac
done

echo "stopping distractions"

stock_blocklist="/usr/share/prohibify/stock.txt"
user_blocklist="$HOME/.config/prohibify/blocklist.txt"

if [[ -f "$user_blocklist" ]]; then
    blocklist=$(cat $stock_blocklist "$user_blocklist")
else
    blocklist=$(cat $stock_blocklist)
fi

echo "blocklist $blocklist"

function send_notification {
    notify-send "Prohibify" "Killed $1 to stop distractions"
    zenity --warning --text="Killed $1 to stop distractions"
}

function kill_program {
    local program=$1
    local match_type=${2:-full}
    local force_kill=$3
    local kill_command=""

    if [[ $force_kill == "force" ]]; then
        kill_command="pkill -9"
    else
        kill_command="pkill"
    fi

    if [[ $match_type == "full" ]]; then
        if $kill_command -x "$program"; then
            send_notification "$program"
        fi
    elif [[ $match_type == "partial" ]]; then
        if $kill_command "$program"; then
            send_notification "$program"
        fi
    else
        echo "Invalid match type: $match_type"
    fi
}

while true; do
    while IFS= read -r line; do
        # Skip empty or invalid lines
        if [[ -z "$line" || ! $line =~ ^[a-zA-Z0-9_:.-]+$ ]]; then
            continue
        fi
        echo "checking $line"
        IFS=':' read -ra ADDR <<<"$line"
        program=${ADDR[0]}
        match_type=""
        force_kill=""
        for i in "${ADDR[@]:1}"; do
            if [[ $i == "full" || $i == "partial" ]]; then
                match_type=$i
            elif [[ $i == "force" ]]; then
                force_kill=$i
            fi
        done
        kill_program "$program" "$match_type" "$force_kill"
        sleep 1
    done <<<"$blocklist"
    sleep 1
done

