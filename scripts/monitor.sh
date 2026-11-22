#!/usr/bin/env bash
set -euo pipefail
PROJETO="${PROJETO:-final-equipeN}"
while true; do clear; date; lxc --project "$PROJETO" list -c ns4mDu; echo; lxc query /1.0/metrics | grep -E 'cpu_seconds_total|memory_MemAvailable_bytes|filesystem_avail_bytes' | head -12; sleep 5; done

