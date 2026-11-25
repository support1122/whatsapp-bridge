#!/bin/bash
set -e

mkdir -p /data/media /data/backups

# Start nginx in background (daemon mode off so it stays running)
nginx -g "daemon off;" &
NGINX_PID=$!

# Give nginx a moment to bind port 8080
sleep 1

# Start whatsapp bridge in foreground — this keeps the container alive
/bin/whatsapp-bridge &
BRIDGE_PID=$!

# If either process dies, kill the other and exit
wait -n $NGINX_PID $BRIDGE_PID
kill $NGINX_PID $BRIDGE_PID 2>/dev/null
exit 1
