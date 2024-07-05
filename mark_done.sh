#!/bin/bash
#
# fzf over today tasks from repeats.rem and mark picked as "done"

# exit if one of the commands exited with non-zero code
set -e

DONES_LIST="$HOME/.reminders/dones"
TASKS_REM="$HOME/.reminders/repeats.rem"

if [ -n "$1" ]; then
    date_offset="$1 day"
    # leave first "+" if it is, otherwise prefix with "-"
    if [ "${date_offset:0:1}" != "+" ]; then
        date_offset="-$date_offset"
    fi
fi

wanted_date="$(date -d "$date_offset" +'%Y-%m-%d')"

pick=$(rem "$wanted_date" \
    | grep -xF -f \
        <(rg -o ' MSG (.*)' -r '$1' "$TASKS_REM") \
    | fzf)

res=$(printf '%(%Y-%m-%d)T '; echo "$pick")

echo "$res" >> "$DONES_LIST"
# re-generate dones list
"$(dirname "$0")"/regen_dones.sh
