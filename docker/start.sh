#!/bin/bash
set -e

mkdir -p /data/media /data/backups

# Start whatsapp bridge in background
/bin/whatsapp-bridge &

# Give bridge a moment to bind port 9090
sleep 2

# Start nginx in foreground — keeps container alive, proxies 8080 -> 9090
exec nginx -g "daemon off;"
