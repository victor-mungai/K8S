#!/bin/bash

random_delay() {
    awk -v min="$1" -v max="$2" 'BEGIN{srand(); print min+rand()*(max-min)}'
}

load_phase() {
    local label="$1"
    local min_dur="$2"
    local max_dur="$3"
    local min_delay="$4"
    local max_delay="$5"

    local duration=$((RANDOM % (max_dur - min_dur + 1) + min_dur))
    local delay
    delay=$(random_delay "$min_delay" "$max_delay")

    echo "$(date '+%F %T') -> $label for $duration sec (delay: $delay)"

    local end=$((SECONDS + duration))

    while (( SECONDS < end )); do
        curl -s http://localhost:5000/ >/dev/null &
        sleep "$delay"
    done
}

while true; do
    load_phase "HIGH load" 60 180 0.1 1
    load_phase "LOW load"  60 240 1   3
done

