#! /bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 [FILE]"
    exit 1
fi

ASAN_OPTIONS=symbolize=0:print_stacktrace=0 GODEBUG=asyncpreemptoff=1 GOMAXPROCS=1 GOTRACEBACK=crash MAYHEM_TRIAGING=1 /out/fuzz_parse_bgp_message $1