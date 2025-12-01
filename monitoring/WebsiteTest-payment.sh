#!/bin/sh

# POSIX random float using awk
random_float() {
    min=$1
    max=$2
    awk -v min="$min" -v max="$max" 'BEGIN{srand(); print min+rand()*(max-min)}'
}

# POSIX random integer using awk
random_int() {
    min=$1
    max=$2
    awk -v min="$min" -v max="$max" 'BEGIN{srand(); print int(min+rand()*(max-min+1))}'
}

load_phase() {
    phase="$1"
    min_dur="$2"
    max_dur="$3"
    min_delay="$4"
    max_delay="$5"

    duration=$(random_int "$min_dur" "$max_dur")
    delay=$(random_float "$min_delay" "$max_delay")

    echo "$(date '+%F %T') → $phase for $duration sec (delay: $delay)"

    start=$(date +%s)
    end=$((start + duration))

    while : ; do
        now=$(date +%s)
        [ "$now" -ge "$end" ] && break

        curl -s --max-time 2 http://localhost:5000/payment >/dev/null &
        sleep "$delay"
    done
}

while true; do
    load_phase "High load" 60 180 0.1 1
    load_phase "Low load"  60 240 1 3
done

