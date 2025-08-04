#!/bin/bash

# mal
# malcontent

set -e

docker run --rm -v $(pwd):/work -w /work cgr.dev/chainguard/malcontent:latest "$@"
