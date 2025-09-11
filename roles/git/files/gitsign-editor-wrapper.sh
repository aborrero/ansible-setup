#!/bin/bash

set -e
set -o pipefail

$EDITOR "$@"
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    (sleep 1; gscc >/dev/null 2>/dev/null) &
fi

exit $EXIT_CODE
