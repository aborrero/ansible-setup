#!/bin/bash

set -e
set -o pipefail

make debug/$1
make test-debug/$1
