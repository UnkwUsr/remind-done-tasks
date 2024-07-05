#!/bin/bash
#
# this script generates `.generated_dones.rem` file from list from `dones` file

# 'dones' file format example: `2023-02-19 all the trailing is task name`
SRC_FILE="$HOME/.reminders/dones"
DEST_FILE="$HOME/.reminders/.generated_dones.rem"
VAR_NAME_PREFIX="d_"
HASH_CHARS_COUNT=5

# take uniq tasks with oldest date:
# 0. take only non-empty lines
# 1. sort by task name, then by date (in reverse order)
# 2. then remove duplicates by task name, taking first occurrences, which will
#    be oldest by date (because we reversed order for dates in previous step)
uniq_dones=$(grep . "$SRC_FILE" | sort -k2 -k1,1r | sort -u -k2)

hashes_file_temp=$(mktemp --suffix=_rem_gen_dones_hashes)

while IFS=' ' read -r date task
do
    # TODO: allow empty lines
    if [ -z "$task" ]; then
        echo "Orphan date: $date" >&2
        continue
    fi

    hash=$(echo -n "$task" | md5sum | head -c "$HASH_CHARS_COUNT")
    echo "$hash" >> "$hashes_file_temp"

    date=$(date -d "$date +1 day" +'%Y-%m-%d')

    echo -e "# $task\nSET $VAR_NAME_PREFIX$hash \"FROM $date\"\n"

done <<< "$uniq_dones" > "$DEST_FILE"

# find duplicate hashes
dup_hashes=$(cat "$hashes_file_temp" | sort | uniq -d)
rm "$hashes_file_temp"
if [ ! -z "$dup_hashes" ]; then
    echo "ALARM: have duplicate hashes" | tee "$DEST_FILE" >&2
    echo "$dup_hashes" >&2
    exit 1
fi
