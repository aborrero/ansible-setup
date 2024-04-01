#!/bin/bash

set -eo pipefail

if [ "$DISPLAY" == "" ] ; then
    echo "ERROR: empty \$DISPLAY env variable. Refusing to run conky" >&2
    exit 1
fi

# pause so in case of triple monitor, it starts on the right one
conky --pause=20
