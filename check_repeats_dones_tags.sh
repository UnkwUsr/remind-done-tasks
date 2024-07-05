#!/bin/bash
#
# it checks that in repeats.rem you set right [d_hash] tag

HASH_CHARS_COUNT=5
TASKS_REM="$HOME/.reminders/repeats.rem"

sed -n -E  's/.+\[d_(.{'$HASH_CHARS_COUNT'})\] MSG (.+$)/\1 \2/p' "$TASKS_REM" \
| while IFS=' ' read -r hash task
do
    new_hash=$(echo -n "$task" | md5sum | head -c "$HASH_CHARS_COUNT")
    if [ "$hash" = "$new_hash" ]; then
        echo "Ok for: $task"
    else
        echo "Wrong hash for: $task"
        echo "   Have:      d_$hash"
        echo "   Should be: d_$new_hash"
    fi
done
