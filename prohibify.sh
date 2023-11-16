#!/bin/bash

# Copyright (C) 2023 paperbenni <paperbenni@gmail.com>
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.


version="0.0.1"

function show_help {
  echo "Usage: prohibify.sh [OPTION]..."
  echo "Periodically kill programs in a blocklist to stop distractions."
  echo ""
  echo "Options:"
  echo "  --help     display this help and exit"
  echo "  --version  output version information and exit"
  echo ""
  echo "Example blocklist:"
  echo "  firefox:partial"
  echo "  solitaire"
  echo "The first line will kill any process with 'firefox' in its name."
  echo "The second line will only kill processes named exactly 'solitaire'."
}

while (( "$#" )); do
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

while true; do
  while IFS= read -r line; do
    # Skip empty or invalid lines
    if [[ -z "$line" || ! $line =~ ^[a-zA-Z0-9_:.-]+$ ]]; then
      continue
    fi
    echo "checking $line"
    if [[ $line == *":"* ]]; then
      program=$(echo "$line" | cut -d':' -f1)
      match_type=$(echo "$line" | cut -d':' -f2)
    else
      program=$line
      match_type="full"
    fi
    if [[ $match_type == "full" ]]; then
      if pkill -x "$program"; then
        send_notification "$program"
      fi
    else
      if pkill "$program"; then
        send_notification "$program"
      fi
    fi
    sleep 1
  done <<< "$blocklist"
  sleep 1
done


