#!/bin/sh

# workaround for debian bug: https://bugs.debian.org/991788

case $1/$2 in
    pre/*)
        #echo "Going to $2..."
        exit 0
        ;;
    post/*)
        echo "Waking up from $2..."
        sleep 5
        sudo -iu arturo profiler exec screen_post_suspend
        ;;
esac
