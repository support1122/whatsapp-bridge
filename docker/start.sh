#!/bin/bash
set -e

mkdir -p /data/media /data/backups

# Validate nginx config before starting anything
nginx -t 2>&1 || { echo "nginx config invalid, aborting"; exit 1; }

# Start whatsapp bridge in background
/bin/whatsapp-bridge &
BRIDGE_PID=$!

# Wait until bridge is listening on 9090 (up to 15s)
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if kill -0 $BRIDGE_PID 2>/dev/null && grep -q "0000:2352\|00000000:2352" /proc/net/tcp 2>/dev/null; then
        echo "bridge listening on 9090 after ${i}s"
        break
    fi
    if ! kill -0 $BRIDGE_PID 2>/dev/null; then
        echo "bridge process exited early"
        exit 1
    fi
    sleep 1
done

echo "starting nginx"
# Start nginx in foreground — keeps container alive, proxies 8080 -> 9090
exec nginx -g "daemon off;"
