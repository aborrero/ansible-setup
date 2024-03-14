#!/bin/bash

set -eo pipefail

SLEEP=2
PAUSE=5

while [ "$DISPLAY" == "" ] ; do
    echo "WARNING: empty \$DISPLAY env variable, retriyng in $SLEEP seconds" >&2
    sleep $SLEEP
done

conky --pause=$PAUSE
