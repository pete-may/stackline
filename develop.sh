#!/usr/bin/env bash

pgrep -q Hammerspoon  \
    && hs -c 'stackline.test()'  \
    || hs -A -c 'print()'

# function test {
#     hs -A -c 'print("restarting")'
#     hs -c 'stackline.test()'
# }

# is_running=$(pgrep Hammerspoon )


# until test; do
#      echo "Server 'myserver' crashed with exit code $?.  Respawning.." >&2
#      sleep 1
#  done

