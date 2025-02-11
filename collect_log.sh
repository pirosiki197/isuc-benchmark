#!/bin/bash

set -eu

CACHE=$1

if [ $CACHE != "cache" ] && [ $CACHE != "nocache" ]; then
    echo "Usage: $0 <cache|nocache>"
    exit 1
fi

GIT_HASH=$(git rev-parse --short HEAD)
OUT_DIR="logs/$CACHE/$GIT_HASH"
EXEC_USER=$(whoami)

mkdir -p "$OUT_DIR"

LOG_FILES=(
    "/var/log/mysql/mysql-slow.log"
    "/var/log/nginx/access.log"
)

for LOG_FILE in "${LOG_FILES[@]}"; do
    if [ -f "$LOG_FILE" ]; then
        sudo cp "$LOG_FILE" "$OUT_DIR/$(basename "$LOG_FILE")"
        sudo truncate -s 0 "$LOG_FILE"
        sudo chown "$EXEC_USER:$EXEC_USER" "$OUT_DIR/$(basename "$LOG_FILE")"
        echo "Truncated: $LOG_FILE"
    else
        echo "File not found: $LOG_FILE"
    fi
done

gzip -f "$OUT_DIR"/*.log

echo "Logs collected to $OUT_DIR"
